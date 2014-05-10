require 'spec_helper'

describe "Search#migrate" do
  before :each do
    Search.drop
  end

  context "no current search index" do
    before do
      expect(Search.true_index_name).to be_nil
    end

    it "creates a new index" do
      Search.migrate
      expect(Search.true_index_name).to_not be_nil
    end
  end

  context "obsolete search mapping" do
    before do
      mappings = Search.mappings.dup
      mappings[:paper][:properties][:foo] = { type: 'string' }

      Search.es.index(:scirate_test_old)
            .create(settings: Search.settings, mappings: mappings)
      Search.es.index(:scirate_test_old).alias(:scirate_test).create
      expect(Search.true_index_name).to eq "scirate_test_old"
    end

    it "migrates to a new index with the right mapping" do
      Search.migrate
      expect(Search.true_index_name).to_not be_nil
      expect(Search.true_index_name).to_not eq "scirate_test_old"
    end
  end

  context "obsolete search settings" do
    before do
      settings = Search.settings.dup
      settings[:index][:analysis][:tokenizer][:category_path][:delimiter] = '/'

      Search.es.index(:scirate_test_old)
            .create(settings: settings, mappings: Search.mappings)
      Search.es.index(:scirate_test_old).alias(:scirate_test).create
      expect(Search.true_index_name).to eq "scirate_test_old"
    end

    it "migrates to a new index with the right settings" do
      Search.migrate
      expect(Search.true_index_name).to_not be_nil
      expect(Search.true_index_name).to_not eq "scirate_test_old"
    end
  end

  context "search mappings and settings are current" do
    before do
      Search.drop("scirate_test_v1")
      Search.drop("scirate_test_v2")
      Search.migrate('v1')
    end

    it "does not migrate to a new index" do
      index_name = Search.true_index_name
      Search.migrate('v2')
      expect(Search.true_index_name).to eq index_name
    end
  end
end

describe "search fields" do
  it "allows searching for a paper by uid" do
    paper1 = FactoryGirl.create(:paper)
    paper2 = FactoryGirl.create(:paper)

    Search.refresh
    uids = Search::Paper.query_uids(paper1.uid)
    expect(uids).to eq [paper1.uid]
  end

  it "allows searching for papers in a particular category" do
    feed = FactoryGirl.create(:feed)
    paper1 = FactoryGirl.create(:paper)
    paper2 = FactoryGirl.create(:paper)
    paper1.categories.create(feed_uid: feed.uid, position: paper1.categories.length+1)
    paper1.reload
    Search::Paper.index(paper1)

    Search.refresh
    uids = Search::Paper.query_uids("in:#{feed.uid}")
    expect(uids).to eq [paper1.uid]
    uids = Search::Paper.query_uids("in:#{feed.uid.split('.')[0]}")
    expect(uids).to include paper1.uid
  end

  it "allows searching for papers scited by a user" do
    user = FactoryGirl.create(:user)
    user2 = FactoryGirl.create(:user)
    paper1 = FactoryGirl.create(:paper)
    paper2 = FactoryGirl.create(:paper)

    user.scite!(paper1)
    paper1.reload
    Search::Paper.index(paper1)

    Search.refresh
    uids = Search::Paper.query_uids("scited_by:#{user.username}")
    expect(uids).to eq [paper1.uid]

    uids = Search::Paper.query_uids("scited_by:#{user2.username}")
    expect(uids).to eq []

    # Make sure this works with duplicate fullnames
    user2.fullname = user.fullname
    user2.save
    uids = Search::Paper.query_uids("scited_by:(#{user.fullname})")
    expect(uids).to eq [paper1.uid]
  end
end
