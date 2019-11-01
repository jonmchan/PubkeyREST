# PubkeyREST - Pubkey RESTful Microservice

![pubkey restful microservice](https://www.puppyfaqs.com/wp-content/uploads/2018/09/how-much-do-puppies-sleep-at-8-weeks-1020x520.jpg)

Very simple REST microservice exposing basic OpenSSL Public/Private key encryption methods. Generates and stores its own pub/private keys in a sqlite DB.

## Installation

## Environment Variables

```bash
PRIVATE_KEY_ACCESSIBLE=false
SQLITE_FILE_LOCATION=
# if unset, the private keys will be stored with no encryption in the SQLiteDB
PRIVATE_KEY_PASSPHRASE=
```

## Endpoints

POST /new params: { name }, returns: { name, id }

GET /:id/public_key

GET /:id/private_key (disabled unless PRIVATE_KEY_ACCESSIBLE=true environment variable is set)

/:id/sign

/:id/verify

/:id/encrypt

/:id/decrypt
