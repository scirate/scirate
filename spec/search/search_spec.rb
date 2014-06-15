require 'spec_helper'

describe "search fields" do
  it "allows searching for a paper by uid" do
    paper1 = FactoryGirl.create(:paper)
    paper2 = FactoryGirl.create(:paper)

    Search::Paper.index(paper1, paper2)
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

    Search::Paper.index(paper1, paper2)
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

    Search::Paper.index(paper1, paper2)
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

  it "handles a variety of edge cases" do
    paper = FactoryGirl.create(:paper)
    searchterms = ['~T_Avid', 'Nishino_H%2B', "Morf'%5B?%5D_J"]
    searchterms.each do |term|
      FactoryGirl.create(:author, searchterm: term, paper: paper)
    end

    paper.reload
    Search::Paper.index(paper)
    Search.refresh

    paper.authors.each do |author|
      uids = Search::Paper.query_uids("au:#{author.searchterm}")
      expect(uids).to eq [paper.uid]
    end
  end
end
