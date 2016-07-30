require 'active_record'
require 'yaml'
require 'erb'

# Connect with the database
ENV['RACK_ENV'] ||= 'development'
config = YAML::load(ERB.new(IO.read(File.join(File.dirname(__FILE__), '..', 'db', 'config.yml'))).result)[ENV['RACK_ENV']]
ActiveRecord::Base.establish_connection(config)

# require all the models
require 'shortlink'
require 'campaign'
