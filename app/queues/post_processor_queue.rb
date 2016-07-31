require 'logger'

class PostProcessorQueue
  @queue = :post_processor

  def self.perform(parameters, headers)
    logger.info "PostProcessorQueue: Processing Parameters:"
    logger.info parameters

    logger.info "PostProcessorQueue: Processing Headers:"
    logger.info headers
  end

  private

  def self.logger
    return @logger if @logger

    log_file = File.open(File.join(File.dirname(__FILE__), '..', '..', 'log', ENV['RACK_ENV'] + '.log'), 'a+')
    log_file.sync = true if ENV['RACK_ENV'] == 'development'
    @logger = Logger.new(log_file)
    @logger.level = Logger::DEBUG
    @logger
  end
end
