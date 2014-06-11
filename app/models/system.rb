# Single row table containing global dynamic SciRate settings
class System < ActiveRecord::Base
  self.table_name = 'system'

  class << self
    def method_missing(meth, *args, &block)
      @system ||= System.first_or_create
      @system.send(meth, *args, &block)
    end
  end
end
