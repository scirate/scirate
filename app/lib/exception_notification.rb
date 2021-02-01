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
