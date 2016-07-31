require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'boot')
require 'database'
require 'cache'
require 'key_hasher'
require 'json'
require 'sinatra'
require 'logger'
require 'resque'
require 'post_processor_queue'

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

resque_config = YAML::load(ERB.new(IO.read(File.join(File.dirname(__FILE__), '..', 'config', 'resque.yml'))).result)[ENV['RACK_ENV']]
Resque.redis = resque_config

# Redirect to sharepop in case no shortlink is provided
get '/' do
  redirect to('http://sharepop.com')
end

get '/dashboard' do
  erb :dashboard, locals: {
    pending: Resque.info[:pending],
    processed: Resque.info[:processed],
    failed: Resque.info[:failed],
    cache: cache.storage
  }
end

get '/:shortlink' do
  retries = 1
  enqueued = false
  loop do
    begin
      Resque.enqueue(PostProcessorQueue, JSON.pretty_generate(params), JSON.pretty_generate(request.env))
      # We can not break below since break will be called within begin-rescue block
      # break will cause begin-rescue block to exit immediately. And control will
      # reach to the end of begin-rescue block. Which will essentially continue
      # the loop. And the loop will never terminate. This is why we use enqueued flag.
      enqueued = true

    rescue Redis::CannotConnectError
      sleep_for = (2**retries * 100) / 1000.0 # By default sleep(n) sleeps for n seconds.
      logger.info "Going to sleep for #{sleep_for} seconds"
      sleep(sleep_for)
      retries += 1
    end
    break if enqueued
  end

  shortlink = cache.fetch(params[:shortlink]) do
     Shortlink.cacheable_object(params[:shortlink])
  end

  if shortlink
    redirect to(shortlink[:offer_url])

  else
    redirect to("http://sharepop.com")
  end
end
