require 'base64'
require 'json'
require 'openssl'
require 'sinatra'
require 'sinatra/json'
require 'sqlite3'
require 'rack/contrib'

require 'sinatra/reloader' if development?


use Rack::Auth::Basic, "Restricted Area" do |username, password|
  (username == ENV['HTTP_BASIC_USER'] || ENV['HTTP_BASIC_USER'].nil?) && 
  (password == ENV['HTTP_BASIC_PASS'] || ENV['HTTP_BASIC_PASS'].nil?)
end

$db = SQLite3::Database.new(ENV['SQLITE_FILE_LOCATION'] || "keypairs.db")

$db.execute <<-SQL
  CREATE TABLE IF NOT EXISTS keypairs (
    id INTEGER PRIMARY KEY,
    name text,
    public_key text,
    private_key text
  );
SQL


## if you want to change the key or the cipher, here is the place to do it.
def new_keypair
  key           = OpenSSL::PKey::RSA.new 2048
  public_key    = key.public_key.to_pem

  if ENV['PRIVATE_KEY_PASSPHRASE']
    cipher      = OpenSSL::Cipher.new 'AES-128-CBC'
    private_key = key.export(cipher, ENV['PRIVATE_KEY_PASSPHRASE'])
  else
    private_key = key.to_pem
  end

  [public_key, private_key]
end

def find_keypair id
  query = $db.prepare("SELECT * FROM keypairs WHERE id = ?")
  query.bind_param 1, id

  result = query.execute
  record = result.next_hash
  
  not_found(json({ error: "No keypair with id '#{id}' found" })) if record.nil?

  record
end

def load_key id
  record = find_keypair id
  begin
    OpenSSL::PKey::RSA.new(record['private_key'], ENV['PRIVATE_KEY_PASSPHRASE'])
  rescue OpenSSL::PKey::RSAError
    halt(500, json(error:"Cannot unlock private record. Please ensure ENV['PRIVATE_KEY_PASSPHRASE'] was not changed!"))
  end
end

def process_payload(operation, id, payload)
  if operation == "verify"
    halt(422, json(error:"invalid payload - payload must be hash or array")) unless payload.is_a?(Hash) || payload.is_a?(Array)
  else
    halt(422, json(error:"invalid payload - payload must be string or array")) unless payload.is_a?(String) || payload.is_a?(Array)
  end

  key = load_key(id)

  digest = OpenSSL::Digest::SHA256.new

  payload = [payload] if payload.is_a? String
  payload = [payload] if payload.is_a? Hash

  response = payload.map do |element|
    case operation
    when "sign"
      Base64.encode64(key.sign(digest,element))
    when "verify"
      halt(422, json(error:"verify must pass in signature and document in hash")) unless element.is_a? Hash
      halt(422, json(error:"verify must pass in signature and document in hash")) if element['signature'].nil?
      halt(422, json(error:"verify must pass in signature and document in hash")) if element['document'].nil?
      key.verify(digest, Base64.decode64(element['signature']), element['document'])
    when "encrypt"
      Base64.encode64(key.public_encrypt(element))
    when "decrypt"
      key.private_decrypt(Base64.decode64(element))
    else
      halt(500, json(error:"Unknown/Invalid operation #{operation}"))
    end
  end

  return response.first if response.length == 1

  response
end

use Rack::PostBodyContentTypeParser

# suppress sinatras jazzy 404 page (sorry sinatra)
not_found do 
  "Not Found"
end

get '/' do
  '<html><head><title>Pubkey RESTful Microservice</title><body><img src="https://www.puppyfaqs.com/wp-content/uploads/2018/09/how-much-do-puppies-sleep-at-8-weeks-1020x520.jpg"></body></html>'
end

post '/' do
  public_key, private_key = new_keypair
  query = $db.execute("INSERT INTO keypairs (name, public_key, private_key) VALUES ( ?, ?, ?)", params['name'], public_key, private_key )
  id = $db.last_insert_row_id
  json( {key: { id: id, name: params['name'], public_key: public_key }})
end

get '/:id' do
  record = find_keypair(params[:id])
  record.delete('private_key')
  record.delete('public_key')
  json(record)
end

get '/:id/public_key' do
  content_type 'text/plain'
  record = find_keypair(params[:id])
  record['public_key']
end

if ENV['PRIVATE_KEY_ACCESSIBLE'] == 'true'
  get '/:id/private_key' do
    record = find_keypair(params[:id])
    record['private_key']
  end
end

post '/:id/sign' do
  halt(422, json(error:"Missing payload")) if params['payload'].nil?
  json(result: process_payload('sign', params['id'], params['payload']))
end

post '/:id/verify' do
  halt(422, json(error:"Missing payload")) if params['payload'].nil?
  json(result: process_payload('verify', params['id'], params['payload']))
end

post '/:id/encrypt' do
  halt(422, json(error:"Missing payload")) if params['payload'].nil?
  json(result: process_payload('encrypt', params['id'], params['payload']))
end

post '/:id/decrypt' do
  halt(422, json(error:"Missing payload")) if params['payload'].nil?
  json(result: process_payload('decrypt', params['id'], params['payload']))
end

