require 'sequel'
module Checker
  DB = Sequel.connect("postgres://#{ENV["DB_USER"]}:#{ENV["DB_PASS"]}@#{ENV["DB_HOST"]}/#{ENV["DB_BASE"]}")
end
