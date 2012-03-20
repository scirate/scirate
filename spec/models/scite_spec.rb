# == Schema Information
#
# Table name: scites
#
#  id         :integer         not null, primary key
#  sciter_id  :integer
#  paper_id   :integer
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

require 'spec_helper'

describe Scite do
  
  let (:sciter) { FactoryGirl.create(:user) }
  let (:paper)  { FactoryGirl.create(:paper) }
  let(:scite) do
    sciter.scites.build(paper_id: paper.id)
  end

  subject { scite }

  it { should be_valid }

  describe "sciter methods" do
    before { scite.save }

    it { should respond_to(:sciter) }
    it { should respond_to(:paper) }
    its(:sciter) { should == sciter }
    its(:paper)  { should == paper }
  end

  describe "when sciter id is not present" do
    before { scite.sciter_id = nil }
    it { should_not be_valid }
  end

  describe "when follower id is not present" do
    before { scite.paper_id = nil }
    it { should_not be_valid }
  end
end
