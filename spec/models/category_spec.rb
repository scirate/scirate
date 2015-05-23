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
  it { is_expected.to belong_to(:paper) }
  it { is_expected.to belong_to(:feed) }
  it { is_expected.to validate_presence_of(:paper_uid) }
  it { is_expected.to validate_presence_of(:feed_uid) }
end
