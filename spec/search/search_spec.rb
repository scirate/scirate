require 'spec_helper'

describe "search migrations" do
  before :each do
    Search.drop
  end

  it "should create a new index if one doesn't exist" do
    Search.true_index_name.should be_nil
    Search.migrate
    Search.true_index_name.should_not be_nil
  end

  it "should migrate if the current mapping is obsolete" do
    mappings = Search.mappings.dup
    mappings[:paper][:properties][:foo] = { type: 'string' }

    Search.es.index(:scirate_test_old).create(settings: Search.settings, mappings: mappings)
    Search.es.index(:scirate_test_old).alias(:scirate_test).create
    Search.true_index_name.should == "scirate_test_old"

    Search.migrate
    Search.true_index_name.should_not be_nil
    Search.true_index_name.should_not == "scirate_test_old"
  end

  it "should migrate if the current setting is obsolete" do
    settings = Search.settings.dup
    settings[:index][:analysis][:tokenizer][:category_path][:delimiter] = '/'

    Search.es.index(:scirate_test_old).create(settings: settings, mappings: Search.mappings)
    Search.es.index(:scirate_test_old).alias(:scirate_test).create
    Search.true_index_name.should == "scirate_test_old"

    Search.migrate
    Search.true_index_name.should_not be_nil
    Search.true_index_name.should_not == "scirate_test_old"
  end

  it "should not migrate if the mapping/setting is current" do
    Search.drop
    Search.migrate('v1')
    index_name = Search.true_index_name
    Search.migrate('v2')
    Search.true_index_name.should == index_name
  end
end

describe "search fields" do
  it "should allow searching for a paper by uid" do
    paper1 = FactoryGirl.create(:paper)
    paper2 = FactoryGirl.create(:paper)

    Search.refresh
    uids = Search::Paper.query_uids(paper1.uid)
    uids.should == [paper1.uid]
  end

  it "should allow searching for papers in a particular category" do
    feed = FactoryGirl.create(:feed)
    paper1 = FactoryGirl.create(:paper)
    paper2 = FactoryGirl.create(:paper)
    paper1.categories.create(feed_uid: feed.uid, position: paper1.categories.length+1)
    paper1.reload
    Search::Paper.index(paper1)

    Search.refresh
    uids = Search::Paper.query_uids("in:#{feed.uid}")
    uids.should == [paper1.uid]
  end

  it "should allow searching for papers scited by a user" do
    user = FactoryGirl.create(:user)
    user2 = FactoryGirl.create(:user)
    paper1 = FactoryGirl.create(:paper)
    paper2 = FactoryGirl.create(:paper)

    user.scite!(paper1)
    paper1.reload
    Search::Paper.index(paper1)

    Search.refresh
    uids = Search::Paper.query_uids("scited_by:#{user.username}")
    uids.should == [paper1.uid]

    uids = Search::Paper.query_uids("scited_by:#{user2.username}")
    uids.should == []

    # Make sure this works with duplicate fullnames
    user2.fullname = user.fullname
    user2.save
    uids = Search::Paper.query_uids("scited_by:(#{user.fullname})")
    uids.should == [paper1.uid]
  end
end
