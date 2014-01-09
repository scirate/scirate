# == Schema Information
#
# Table name: papers
#
#  id             :integer         primary key
#  title          :string(255)
#  abstract       :text
#  identifier     :string(255)
#  url            :string(255)
#  created_at     :timestamp       not null
#  updated_at     :timestamp       not null
#  pubdate        :date
#  updated_date   :date
#  scites_count   :integer         default(0)
#  comments_count :integer         default(0)
#  feed_id        :integer
#

require 'spec_helper'
require 'arxivsync'

describe "arxiv importer" do
  it "should import correctly" do
    puts "Starting test"
    archive = ArxivSync::XMLArchive.new("#{Rails.root.to_s}/spec/data/arxiv")

    archive.read_metadata do |models|
      papers = Paper.arxiv_import(models, validate: false)

      papers.length.should == 1000
      paper = papers[0]
      paper.reload
      paper.title.should == "Revisiting Norm Estimation in Data Streams"
      paper.identifier.should == "0811.3648"
      paper.authors[0].fullname.should == "Daniel M. Kane"
      paper.authors[0].searchterm.should == "Kane_D"
      paper.authors[0].position.should == 0
      paper.authors[1].fullname.should == "Jelani Nelson"
      paper.authors[2].fullname.should == "David P. Woodruff"
      paper.authors[2].position.should == 2
      paper.feed.name.should == "cs.DS"
      paper.pubdate.to_s.should == "2008-11-21"
      paper.updated_date.to_s.should == "2009-04-08"
      paper.pdf_url.should == "http://arxiv.org/pdf/0811.3648.pdf"
    end
  end
end
