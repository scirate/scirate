require 'spec_helper'
require 'arxivsync'
require 'arxiv_import'
describe "search migrations" do
  before :all do
    @paper1 = FactoryGirl.create(:paper)
  end

  it "should create a new index if one doesn't exist" do
    Search.drop
    Search.true_index_name.should be_nil
    Search.migrate
    Search.true_index_name.should_not be_nil
  end

  it "should migrate if the current mapping is obsolete" do
    Search.drop

    old_mappings = Search.mappings.dup
    old_mappings[:paper][:properties][:foo] = { type: 'string' }

    Search.es.index(:scirate_test_old).create(mappings: old_mappings)
    Search.es.index(:scirate_test_old).alias(:scirate_test).create
    Search.true_index_name.should == "scirate_test_old"

    Search.migrate
    Search.true_index_name.should_not be_nil
    Search.true_index_name.should_not == "scirate_test_old"
  end

  it "should not migrate if the mapping is current" do
    Search.drop
    Search.migrate('v1')
    index_name = Search.true_index_name
    Search.migrate('v2')
    Search.true_index_name.should == index_name
  end
end
