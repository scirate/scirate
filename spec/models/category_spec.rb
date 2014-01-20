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
  let(:paper) { FactoryGirl.create(:paper) }

  let(:category) do
    paper.categories.build(feed_uid: "waffles", position: 0)
  end

  subject{ category }

  it { should be_valid }
end
