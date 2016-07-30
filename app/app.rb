require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'boot')
require 'database'
require 'cache'
require 'key_hasher'
require 'sinatra'
require 'logger'

ENV['RACK_ENV'] ||= 'development'

# Configure the logger for current environment.
configure do
  log_file = File.open(File.join(File.dirname(__FILE__), '..', 'log', ENV['RACK_ENV'] + '.log'), 'a+')
  log_file.sync = true if ENV['RACK_ENV'] == 'development'
  logger = Logger.new(log_file)
  logger.level = Logger::DEBUG
  set :logger, logger
end

# Return logger and save it in Sinatra `setting` object.
def logger; settings.logger; end

cache_config = YAML::load(ERB.new(IO.read(File.join(File.dirname(__FILE__), '..', 'config', 'cache.yml'))).result)[ENV['RACK_ENV']]

cache = Cache.new(KeyHasher, logger, cache_config["expire_after"])

# Redirect to sharepop in case no shortlink is provided
get '/' do
  redirect to('http://sharepop.com')
end

get '/:shortlink' do
  shortlink = cache.fetch(params[:shortlink]) do
     Shortlink.cacheable_object(params[:shortlink])
  end

  if shortlink
    redirect to(shortlink[:offer_url])

  else
    redirect to("http://sharepop.com")
  end
end
