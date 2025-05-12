require 'semantic_logger'

class RetryProxy
  def initialize(target, attempts: 3, on: [Net::ReadTimeout])
    @target = target
    @attempts = attempts
    @on = on
  end

  def logger
      @logger ||= SemanticLogger[self.class.name]
  end

  def method_missing(method_name, *args, &block)
    tries = 0
    begin
      @target.public_send(method_name, *args, &block)
    rescue *@on => e
      logger.error("Retrying due to error", method: method_name, attempts: tries + 1, error: e)
      tries += 1
      retry if tries < @attempts
      raise e
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    @target.respond_to?(method_name, include_private)
  end
end
