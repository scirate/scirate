# == Schema Information
#
# Table name: system
#
#  id                   :integer          not null, primary key
#  alert                :text             default(""), not null
#  created_at           :datetime
#  updated_at           :datetime
#  arxiv_sync_dt        :datetime         default(2014-09-08 00:00:00 UTC), not null
#  arxiv_author_sync_dt :datetime         default(2014-09-08 00:00:00 UTC), not null
#

# Single row table containing global dynamic SciRate settings
class System < ActiveRecord::Base
  self.table_name = 'system'

  class << self
    def method_missing(meth, *args, &block)
      @system ||= System.first_or_create
      @system.send(meth, *args, &block)
    end

    def reload
      @system = System.first_or_create
    end
  end
end
