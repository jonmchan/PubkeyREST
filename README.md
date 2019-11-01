# PubkeyREST - Pubkey RESTful Microservice

![pubkey restful microservice](https://www.puppyfaqs.com/wp-content/uploads/2018/09/how-much-do-puppies-sleep-at-8-weeks-1020x520.jpg)

Very simple REST microservice exposing basic OpenSSL Public/Private key encryption methods. Generates and stores its own pub/private keys in a sqlite DB.

## Installation

PubkeyREST is a Sinatra Ruby application. You will need ruby and bundler installed.

Run the following to get started:



```
bundle 
bundle exec ruby main.rb -s Puma
```

If all goes well, you should be able to navigate a browser to http://localhost:4567.



## Environment Variables

```bash
PRIVATE_KEY_ACCESSIBLE=false
SQLITE_FILE_LOCATION=
# if unset, the private keys will be stored with no encryption in the SQLiteDB
## WARNING - do NOT change this or lose this 
## passphrase or all your keys will be INACCESSIBLE!
PRIVATE_KEY_PASSPHRASE=

# Basic HTTP Auth if so desired; if not set, no authentication required
HTTP_BASIC_USER=
HTTP_BASIC_PASS=
```

## Endpoints

**POST /new params: { name }, returns: { name, id }**

**GET /:id returns: { id, name }**

**GET /:id/public_key**

**GET /:id/private_key** (disabled unless PRIVATE_KEY_ACCESSIBLE=true environment variable is set)

**POST /:id/sign { payload }**

**POST /:id/verify { payload }**

**POST /:id/encrypt { payload }**

**POST /:id/decrypt { payload }**

Payload can be either a string to validate a single payload or an array of strings. For array, each string element  will be acted upon independently and the return value will be in a corresponding array.
