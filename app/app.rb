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

def logger; settings.logger; end

# Redirect to sharepop in case no shortlink is provided
get '/' do
  redirect to('http://sharepop.com')
end

get '/:shortlink' do
  "#{params[:shortlink]}"
end
