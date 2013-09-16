# == Schema Information
#
# Table name: feed_preferences
#
#  id                     :integer         primary key
#  user_id                :integer
#  feed_id                :integer
#  last_visited           :timestamp
#  previous_last_visited  :timestamp
#  selected_range         :integer

class FeedPreference < ActiveRecord::Base
  before_create :set_defaults
  def set_defaults
    self.last_visited = Time.now
    self.previous_last_visited = self.last_visited
    self.selected_range = nil
  end

  def range
    self.selected_range || :since_last
  end

  def pref_update!(range)
    if range == :since_last
      self.selected_range = nil
    else
      self.selected_range = range
    end
    if self.last_visited + 1.day < Time.now
      self.previous_last_visited = self.last_visited
      self.last_visited = Time.now
    end
    self.save
  end
end
