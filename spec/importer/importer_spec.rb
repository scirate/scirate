require 'spec_helper'
require 'arxivsync'
require 'arxiv_import'

describe "arxiv importer" do
  before(:all) do
    archive = ArxivSync::XMLArchive.new("#{Rails.root.to_s}/spec/data/arxiv")
    archive.read_metadata do |models|
      @models = models
    end
  end

  it "estimates pubdates correctly" do
    # arXiv runs on EST localtime
    # arxiv.org/localtime
    zone = ActiveSupport::TimeZone["EST"]

    time1 = zone.parse("Wed Mar 5 15:59 EST 2014")
    time2 = zone.parse("Wed Mar 5 16:01 EST 2014")
    time3 = zone.parse("Thu Mar 6 01:00 EST 2014")
    expect(Paper.estimate_pubdate(time1)).to eq(zone.parse("Wed Mar 5 20:00 EST 2014"))
    expect(Paper.estimate_pubdate(time2)).to eq(zone.parse("Thu Mar 6 20:00 EST 2014"))
    expect(Paper.estimate_pubdate(time3)).to eq(zone.parse("Thu Mar 6 20:00 EST 2014"))

    time4 = zone.parse("Fri Mar 7 15:59 EST 2014")
    time5 = zone.parse("Fri Mar 7 16:01 EST 2014")
    time6 = zone.parse("Sat Mar 8 15:59 EST 2014")
    time7 = zone.parse("Sat Mar 8 16:01 EST 2014")
    time8 = zone.parse("Sun Mar 9 15:59 EST 2014")
    time9 = zone.parse("Sun Mar 9 16:01 EST 2014")
    time10 = zone.parse("Mon Mar 10 15:59 EST 2014")
    expect(Paper.estimate_pubdate(time4)).to eq(zone.parse("Sun Mar 9 20:00 EST 2014"))
    expect(Paper.estimate_pubdate(time5)).to eq(zone.parse("Mon Mar 10 20:00 EST 2014"))
    expect(Paper.estimate_pubdate(time6)).to eq(zone.parse("Mon Mar 10 20:00 EST 2014"))
    expect(Paper.estimate_pubdate(time7)).to eq(zone.parse("Mon Mar 10 20:00 EST 2014"))
    expect(Paper.estimate_pubdate(time8)).to eq(zone.parse("Mon Mar 10 20:00 EST 2014"))
    expect(Paper.estimate_pubdate(time9)).to eq(zone.parse("Mon Mar 10 20:00 EST 2014"))
    expect(Paper.estimate_pubdate(time10)).to eq(zone.parse("Mon Mar 10 20:00 EST 2014"))
  end

  describe 'when importing papers failed' do
    it 'notifies the errors' do
      allow(Paper).to receive(:import).and_return(double(failed_instances: ['failed']))
      allow(Search::Paper).to receive(:index_by_uids) # stub out indexer
      expect(SciRate::Application).to receive(:notify_error).once

      Arxiv::Import.papers(@models[0..9])
    end
  end

  describe 'when importing versions failed' do
    it 'notifies the errors' do
      allow(Version).to receive(:import).and_return(double(failed_instances: ['failed']))
      expect(SciRate::Application).to receive(:notify_error).once

      Arxiv::Import.papers(@models[0..9])
    end
  end

  describe 'when importing authors failed' do
    it 'notifies the errors' do
      allow(Author).to receive(:import).and_return(double(failed_instances: ['failed']))
      expect(SciRate::Application).to receive(:notify_error).once

      Arxiv::Import.papers(@models[0..9])
    end
  end

  describe 'when importing categories failed' do
    it 'notifies the errors' do
      allow(Category).to receive(:import).and_return(double(failed_instances: ['failed']))
      expect(SciRate::Application).to receive(:notify_error).once

      Arxiv::Import.papers(@models[0..9])
    end
  end

  it "updates existing papers correctly" do
    Arxiv::Import.papers(@models[0..9])

    paper = Paper.find_by_uid(@models[0].id)
    user = FactoryGirl.create(:user)
    FactoryGirl.create(:comment, paper: paper, user: user)
    user.scite!(paper)
    paper.reload

    expect(paper.scites_count).to eq 1
    expect(paper.comments_count).to eq 1
    paper.update_date -= 1.day
    paper.save!

    Arxiv::Import.papers(@models[0..9])

    paper = Paper.find_by_uid(@models[0].id)
    expect(paper.scites_count).to eq 1
    expect(paper.comments_count).to eq 1
  end

  it "imports papers into the database" do
    Search.drop
    Search.migrate

    puts "Starting test"
    paper_uids, updated_uids = Arxiv::Import.papers(@models)

    expect(paper_uids.length).to eq(1000)

    paper = Paper.find_by_uid(paper_uids[0])

    # Primary imports
    expect(paper.uid).to eq("0811.36489")
    expect(paper.submitter).to eq("Jelani Nelson")
    expect(paper.versions[0].date).to eq(Time.parse("Fri, 21 Nov 2008 22:55:07 GMT"))
    expect(paper.versions[0].size).to eq("90kb")
    expect(paper.versions[1].date).to eq(Time.parse("Thu, 9 Apr 2009 02:45:30 GMT"))
    expect(paper.versions[1].size).to eq("71kb")
    expect(paper.title).to eq("Revisiting Norm Estimation in Data Streams")
    expect(paper.author_str).to eq("Daniel M. Kane, Jelani Nelson, David P. Woodruff")
    expect(paper.authors.map(&:fullname)).to eq(["Daniel M. Kane", "Jelani Nelson", "David P. Woodruff"])
    expect(paper.feeds.map(&:uid)).to eq(["cs.DS", "cs.CC"])
    expect(paper.author_comments).to eq("added content; modified L_0 algorithm -- ParityLogEstimator in version 1 contained an error, and the new algorithm uses slightly more space")
    expect(paper.license).to eq("http://arxiv.org/licenses/nonexclusive-distrib/1.0/")
    expect(paper.abstract).to include "The problem of estimating the pth moment F_p"

    # Calculated from above
    expect(paper.submit_date).to eq(Time.parse("Fri, 21 Nov 2008 22:55:07 UTC"))
    expect(paper.update_date).to eq(Time.parse("Thu, 9 Apr 2009 02:45:30 UTC"))
    expect(paper.pubdate).to eq(Time.parse("Tue, 25 Nov 2008 01:00 UTC"))
    expect(paper.abs_url).to eq("http://arxiv.org/abs/0811.36489")
    expect(paper.pdf_url).to eq("http://arxiv.org/pdf/0811.36489.pdf")
    expect(paper.versions_count).to eq 2

    # Ensure last_paper_date is updated on all feeds including parents
    paper.feeds.each do |feed|
      expect(feed.last_paper_date).not_to be_nil
      expect(feed.parent.last_paper_date).not_to be_nil
    end

    # Now test the search index
    Search.refresh

    res   = Search::Paper.es_basic("uid:*")
    total = res["hits"]["total"]["value"]

    expect(total).to eq(1000)

    doc = Search::Paper.es_basic("title:\"Revisiting Norm Estimation in Data Streams\"")["hits"]["hits"][0]["_source"]
    expect(doc["uid"]).to eq("0811.36489")
    expect(doc["title"]).to eq("Revisiting Norm Estimation in Data Streams")
    expect(doc["authors_fullname"]).to eq(["Daniel M. Kane", "Jelani Nelson", "David P. Woodruff"])
    expect(doc["authors_searchterm"]).to eq(["Kane_D", "Nelson_J", "Woodruff_D"])
    expect(doc["feed_uids"]).to eq(["cs.DS", "cs.CC"])
    expect(doc["abstract"]).to include "The problem of estimating the pth moment F_p"
    expect(Time.parse(doc["submit_date"])).to eq(Time.parse("Fri, 21 Nov 2008 22:55:07 UTC"))
    expect(Time.parse(doc["update_date"])).to eq(Time.parse("Thu, 9 Apr 2009 02:45:30 UTC"))
    expect(Time.parse(doc["pubdate"])).to eq(Time.parse("Tue, 25 Nov 2008 01:00 UTC"))

    # And the bulk indexer
    Search.drop
    Search.migrate
    Search.refresh

    res   = Search::Paper.es_basic("uid:*")
    total = res["hits"]["total"]["value"]

    expect(total).to eq(1000)

    doc = Search::Paper.es_basic("title:\"Revisiting Norm Estimation in Data Streams\"")["hits"]["hits"][0]["_source"]
    expect(doc["uid"]).to eq("0811.36489")
    expect(doc["title"]).to eq("Revisiting Norm Estimation in Data Streams")
    expect(doc["authors_fullname"]).to eq(["Daniel M. Kane", "Jelani Nelson", "David P. Woodruff"])
    expect(doc["authors_searchterm"]).to eq(["Kane_D", "Nelson_J", "Woodruff_D"])
    expect(doc["feed_uids"]).to eq(["cs.DS", "cs.CC"])
    expect(doc["abstract"]).to include "The problem of estimating the pth moment F_p"
    expect(Time.parse(doc["submit_date"])).to eq(Time.parse("Fri, 21 Nov 2008 22:55:07 UTC"))
    expect(Time.parse(doc["update_date"])).to eq(Time.parse("Thu, 9 Apr 2009 02:45:30 UTC"))
    expect(Time.parse(doc["pubdate"])).to eq(Time.parse("Tue, 25 Nov 2008 01:00 UTC"))
  end
end
