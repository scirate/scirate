# == Schema Information
#
# Table name: categories
#
#  id             :integer          not null, primary key
#  position       :integer          not null
#  feed_uid       :text             not null
#  paper_uid      :text
#  crosslist_date :datetime         default(2014-01-16 20:06:20 UTC), not null
#

require 'spec_helper'

describe Category do
  it { should belong_to(:paper) }
  it { should belong_to(:feed) }
  it { should validate_presence_of(:paper_uid) }
  it { should validate_presence_of(:feed_uid) }
end
