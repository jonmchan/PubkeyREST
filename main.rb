require 'sqlite3'

require 'sinatra'
require 'sinatra/basic_auth'
require 'sinatra/reloader' if development?


authorize do |username, password|
  (username == ENV['HTTP_BASIC_USER'] || ENV['HTTP_BASIC_USER'].nil?) && 
  (password == ENV['HTTP_BASIC_PASS'] || ENV['HTTP_BASIC_PASS'].nil?)
end

db = SQLite3::Database.new(ENV['SQLITE_FILE_LOCATION'] || "keypairs.db")

db.execute <<-SQL
  CREATE TABLE IF NOT EXISTS keypairs (
    id INTEGER PRIMARY KEY,
    name text,
    public_key text,
    private_key text
  );
SQL

protect do
  get '/' do
    '<html><head><title>Pubkey RESTful Microservice</title><body><img src="https://www.puppyfaqs.com/wp-content/uploads/2018/09/how-much-do-puppies-sleep-at-8-weeks-1020x520.jpg"></body></html>'
  end

  get '/:id' do
    puts params
    'test'
  end

  get '/:id/blah' do
    'test2'
  end
end
