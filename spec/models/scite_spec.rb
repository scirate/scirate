# == Schema Information
#
# Table name: scites
#
#  id       :integer          not null, primary key
#  paper_id :integer          not null
#  user_id  :integer          not null
#

require 'spec_helper'

describe Scite do
  
  let (:user) { FactoryGirl.create(:user) }
  let (:paper)  { FactoryGirl.create(:paper) }
  let(:scite) do
    user.scites.build(paper_id: paper.id)
  end

  subject { scite }

  it { should be_valid }

  describe "user methods" do
    before { scite.save }

    it { should respond_to(:user) }
    it { should respond_to(:paper) }
    its(:user) { should == user }
    its(:paper)  { should == paper }
  end

  describe "when user id is not present" do
    before { scite.user_id = nil }
    it { should_not be_valid }
  end

  describe "when follower id is not present" do
    before { scite.paper_id = nil }
    it { should_not be_valid }
  end
end
