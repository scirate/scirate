# == Schema Information
#
# Table name: authors
#
#  id         :integer          not null, primary key
#  position   :integer          not null
#  fullname   :text             not null
#  searchterm :text             not null
#  paper_uid  :text
#

require 'spec_helper'

describe Author do
  before do
    @author = FactoryGirl.create(:author)
  end

  subject { @author }

  it { should respond_to(:fullname) }
  it { should respond_to(:searchterm) }

  it { should be_valid }

  it "Should generate searchterms correctly" do
    term = Author.make_searchterm("Ben Toner (CWI)")
    term.should == "Toner_B"

    term = Author.make_searchterm("Ben Toner [CWI]")
    term.should == "Toner_B"
  end
end
