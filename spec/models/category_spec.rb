# == Schema Information
#
# Table name: categories
#
#  id        :integer          not null, primary key
#  position  :integer          not null
#  feed_uid  :string(255)      not null
#  paper_uid :string(255)
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
