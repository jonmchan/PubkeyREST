# PubkeyREST - Pubkey RESTful Microservice

![pubkey restful microservice](https://user-images.githubusercontent.com/1827190/68080007-243cf180-fdc1-11e9-9394-be1c83a98830.png)

Very simple REST microservice exposing basic OpenSSL Public/Private key encryption methods. Generates and stores its own pub/private keys in a sqlite DB.

## Installation

PubkeyREST is a Sinatra Ruby application. You will need ruby and bundler installed.

Run the following to get started:



```
bundle 

# Set your variables
export HTTP_BASIC_USER=user
export HTTP_BASIC_PASS=pass
export PRIVATE_KEY_PASSPHRASE=SomeSillyPassphraseToProtectThePrivateKeys

bundle exec ruby main.rb -s Puma
```

If all goes well, you should be able to navigate a browser to http://localhost:4567.



## Environment Variables

```bash
PRIVATE_KEY_ACCESSIBLE=false
SQLITE_FILE_LOCATION=
# if unset, the private keys will be stored with no encryption in the SQLiteDB
## WARNING - after creating keys, do NOT change this or lose this 
## passphrase or all your keys will be INACCESSIBLE!
PRIVATE_KEY_PASSPHRASE=

# Basic HTTP Auth if so desired; if not set, no authentication required
HTTP_BASIC_USER=
HTTP_BASIC_PASS=
```

## Docker

You can also utilize docker to run this microservice:

```bash
docker build -t pubkeyrest:1.0 .
docker run -d --name pubkeyrest -p 4567:4567 pubkeyrest:1.0
```

docker-compose.yml:
```yml
version: '3.3'
  
services:
  pubkeyrest:
    container_name: pubkeyrest
    build: https://github.com/jonmchan/PubkeyREST.git
    environment:
      HTTP_BASIC_USER: someuser
      HTTP_BASIC_PASS: somepass
      PRIVATE_KEY_PASSPHRASE: SomethingReallySecureAndSomewhatLong
    volumes:
      - pubkeydata:/data
    ports:
      - "4567:4567"
volumes:
    pubkeydata: {}
```

## Endpoints

### POST / params: { name }, returns: { name, id } 

Creates a new keypair

```
curl --user "user:pass" -d '{"name":"test"}' -H "Content-Type: application/json" http://localhost:4567/
```

### GET /:id returns: { id, name }

Retrieves the id and name of the keypair.

```
curl --user "user:pass" http://localhost:4567/1
```

### GET /:id/public_key

Retrieves the public key of the keypair.

```
curl --user "user:pass" http://localhost:4567/1/public_key
```

### GET /:id/checksum

Returns the SHA256 checksum of the private key for validating key integrity.

```
curl --user "user:pass" http://localhost:4567/1/checksum
```

### GET /:id/private_key - (disabled unless PRIVATE_KEY_ACCESSIBLE=true environment variable is set)

Retrieves the private key of the keypair

```
curl --user "user:pass" http://localhost:4567/1/private_key
```

### POST /:id/sign { payload } 

Signs the passed in payload. 

Payload as String:
```
curl -v --user "user:pass" -d '{"payload":"Hello"}' -H "Content-Type: application/json" -X POST  http://localhost:4567/1/sign
```

Payload as Array:
```
curl -v --user "user:pass" -d '{"payload":["Hello", "this","test","works"]}' -H "Content-Type: application/json" -X POST  http://localhost:4567/1/sign
```

### POST /:id/verify { payload }

Verifies a signature and a given document. Must pass in payload as a hash with a signature and document element.

Single Payload:
```
curl -v --user "user:pass" -d '{"payload": {"signature":"..signature_hash..","document":"Hello"}}' -H "Content-Type: application/json" -X POST  http://localhost:4567/1/verify
```

Multiple Payloads:
```
curl -v --user "user:pass" -d '{"payload": [{"signature":"..signature_hash..","document":"Hello"},{"signature":"..signature_hash..","document":"this"},{"signature":"..signature_hash..","document":"test"}]}' -H "Content-Type: application/json" -X POST  http://localhost:4567/1/verify
```

### POST /:id/encrypt { payload }

Encrypts the passed in payload. 

Payload as String:
```
curl -v --user "user:pass" -d '{"payload":"Hello"}' -H "Content-Type: application/json" -X POST  http://localhost:4567/1/encrypt
```

Payload as Array:
```
curl -v --user "user:pass" -d '{"payload":["Hello", "this","test","works"]}' -H "Content-Type: application/json" -X POST  http://localhost:4567/1/encrypt
```


### POST /:id/decrypt { payload }

Decrypts the passed in payload.

Payload as String:
```
curl -v --user "user:pass" -d '{"payload":"encryptedstring"}' -H "Content-Type: application/json" -X POST  http://localhost:4567/1/decrypt
```

Payload as Array:
```
curl -v --user "user:pass" -d '{"payload":["encryptedstring1", "encryptedstring2","encryptedstring3","encryptedstring4"]}' -H "Content-Type: application/json" -X POST  http://localhost:4567/1/decrypt
```

Payload can be either a string to validate a single payload or an array of strings. For array, each string element  will be acted upon independently and the return value will be in a corresponding array.
