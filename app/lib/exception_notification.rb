class Exception
  # From http://stackoverflow.com/questions/2823748/how-do-i-add-information-to-an-exception-message-without-changing-its-class-in-r
  def with_details(extra)
    begin
      raise self, "#{message} - #{extra}", backtrace
    rescue Exception => e
      return e
    end
  end
end

module SciRate
  def self.notify_error(exception, message = nil)
    if exception.is_a?(String)
      exception = RuntimeError.new(exception)
    end
    exception = exception.with_details(message) if message
    puts exception.inspect
    puts exception.backtrace.join("\n") if exception.backtrace
    if Rails.env == 'production'
      ExceptionNotifier.notify_exception(exception)
    end
  end
end
