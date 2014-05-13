# == Schema Information
#
# Table name: papers
#
#  id              :integer          not null, primary key
#  uid             :text             not null
#  submitter       :text
#  title           :text             not null
#  abstract        :text             not null
#  author_comments :text
#  msc_class       :text
#  report_no       :text
#  journal_ref     :text
#  doi             :text
#  proxy           :text
#  license         :text
#  submit_date     :datetime         not null
#  update_date     :datetime         not null
#  abs_url         :text             not null
#  pdf_url         :text             not null
#  created_at      :datetime
#  updated_at      :datetime
#  scites_count    :integer          default(0), not null
#  comments_count  :integer          default(0), not null
#  pubdate         :datetime
#  author_str      :text             not null
#

require 'spec_helper'

describe Paper do
  before do
    @paper = FactoryGirl.create(:paper)
  end

  subject { @paper }

  it { should respond_to(:title) }
  it { should respond_to(:authors) }
  it { should respond_to(:abstract) }
  it { should respond_to(:uid) }
  it { should respond_to(:abs_url) }
  it { should respond_to(:pdf_url) }
  it { should respond_to(:submit_date) }
  it { should respond_to(:update_date) }
  it { should respond_to(:scites) }
  it { should respond_to(:sciters) }
  it { should respond_to(:comments) }
  it { should respond_to(:categories) }

  it { should be_valid }

  describe "#to_bibtex" do
    let(:paper) do
      FactoryGirl.create(:paper,
        author_str: "Susanta Kumar Khan and Madhumangal Pal",
        title: "Interval-Valued Intuitionistic Fuzzy Matrices",
        pubdate: "2014-05-12 01:00:00 UTC",
        uid: "1404.6949",
        journal_ref: "Notes on Intuitionistic Fuzzy Sets, 11(1) (2005)16-27"
      )

    end

    it "generates bibtex correctly" do
     expect(paper.to_bibtex).to eq %Q{@misc{1404.6949,
  author = {Susanta Kumar Khan and Madhumangal Pal},
  title = {Interval-Valued Intuitionistic Fuzzy Matrices},
  year = {2014},
  eprint = {1404.6949},
  howpublished = {Notes on Intuitionistic Fuzzy Sets, 11(1) (2005)16-27}
}}
    end
  end

  describe "when update_date is older than submit_date" do
    before { @paper.update_date = @paper.submit_date - 1.day }
    it { should_not be_valid }
  end

  it "should check uid uniqueness" do
    paper_with_same_uid = @paper.dup
    paper_with_same_uid.should_not be_valid
  end

  describe "sciting" do
    let (:user) { FactoryGirl.create(:user) }
    before do
      @paper.save
      user.scite!(@paper)
    end

    its(:sciters) { should include(user) }
  end

  describe "authors" do
    let (:author1) { FactoryGirl.create(:author, paper: @paper, position: 0) }
    let (:author2) { FactoryGirl.create(:author, paper: @paper, position: 1) }

    it "should have the authors in the right order" do
      @paper.reload.authors.should == [author1, author2]
    end
  end

  describe "comments" do
    let (:user) { FactoryGirl.create(:user) }

    before { user.save }

    let!(:old_comment) do
      FactoryGirl.create(:comment,
                         user: user, paper: @paper, created_at: 1.day.ago)
    end
    let!(:new_comment) do
      FactoryGirl.create(:comment,
                         user: user, paper: @paper, created_at: 1.minute.ago)
    end
    let!(:med_comment) do
      FactoryGirl.create(:comment,
                         user: user, paper: @paper, created_at: 1.hour.ago)
    end

    it "should have the right comments in the right order" do
      @paper.comments.should == [old_comment, med_comment, new_comment]
    end
  end
end
