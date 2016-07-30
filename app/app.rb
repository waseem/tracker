require 'sinatra'

ENV['RACK_ENV'] ||= 'development'

# Configure the logger for current development environment.
configure do
  log_file = File.open(File.join(File.dirname(__FILE__), '..', 'log', ENV['RACK_ENV'] + '.log'), 'a+')
  log_file.sync = true if ENV['RACK_ENV'] == 'development'
  logger = Logger.new(log_file)
  logger.level = Logger::DEBUG
  set :logger, logger
end


get '/:shortlink' do
  "#{params[:shortlink]}"
end
