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

  it "has the right properties" do
    @author.should respond_to(:fullname)
    @author.should respond_to(:searchterm)
    @author.should respond_to(:position)

    @author.should be_valid
  end

  it "generates searchterms correctly" do
    term = Author.make_searchterm("Ben Toner (CWI)")
    term.should == "Toner_B"

    term = Author.make_searchterm("Ben Toner [CWI]")
    term.should == "Toner_B"

    term = Author.make_searchterm("BABAR Collaboration")
    term.should == "Collaboration_BABAR"
  end
end
