require 'spec_helper'
require 'arxivsync'
require 'arxiv_import'

describe "arxiv importer" do
  it "should import correctly" do
    puts "Starting test"
    archive = ArxivSync::XMLArchive.new("#{Rails.root.to_s}/spec/data/arxiv")

    archive.read_metadata do |models|
      paper_uids = Arxiv::Import.papers(models, validate: false)

      paper_uids.length.should == 1000

      paper = Paper.find_by_uid(paper_uids[0])

      # Primary imports
      paper.uid.should == "0811.3648"
      paper.submitter.should == "Jelani Nelson"
      paper.versions[0].date.should == Time.parse("Fri, 21 Nov 2008 22:55:07 GMT")
      paper.versions[0].size.should == "90kb"
      paper.versions[1].date.should == Time.parse("Thu, 9 Apr 2009 02:45:30 GMT")
      paper.versions[1].size.should == "71kb"
      paper.title.should == "Revisiting Norm Estimation in Data Streams"
      paper.authors.map(&:fullname).should == ["Daniel M. Kane", "Jelani Nelson", "David P. Woodruff"]
      paper.feeds.map(&:uid).should == ["cs.DS", "cs.CC"]
      paper.author_comments.should == "added content; modified L_0 algorithm -- ParityLogEstimator in version 1 contained an error, and the new algorithm uses slightly more space"
      paper.license.should == "http://arxiv.org/licenses/nonexclusive-distrib/1.0/"
      paper.abstract.should include "The problem of estimating the pth moment F_p"

      # Calculated from above
      paper.submit_date.should == Time.parse("Fri, 21 Nov 2008 22:55:07 GMT")
      paper.update_date.should == Time.parse("Thu, 9 Apr 2009 02:45:30 GMT")
      paper.abs_url.should == "http://arxiv.org/abs/0811.3648"
      paper.pdf_url.should == "http://arxiv.org/pdf/0811.3648.pdf"
    end
  end
end
