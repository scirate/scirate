# == Schema Information
#
# Table name: feed_preferences
#
#  id                    :integer          not null, primary key
#  user_id               :integer
#  last_visited          :datetime
#  previous_last_visited :datetime
#  selected_range        :integer
#  created_at            :datetime
#  updated_at            :datetime
#  feed_uid              :text
#

class FeedPreference < ActiveRecord::Base
end
