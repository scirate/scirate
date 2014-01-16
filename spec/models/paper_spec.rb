# == Schema Information
#
# Table name: papers
#
#  id             :integer          not null, primary key
#  title          :text
#  authors        :text
#  abstract       :text
#  identifier     :string(255)
#  url            :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  submit_date        :date
#  update_date   :date
#  scites_count   :integer          default(0)
#  comments_count :integer          default(0)
#  feed_id        :integer
#  pdf_url        :string(255)
#  author_str     :text
#  delta          :boolean          default(TRUE), not null
#

require 'spec_helper'

describe Paper do
  before do
    @feed = FactoryGirl.create(:feed)
    @paper = @feed.papers.build(title: "On NPT Bound Entanglement and the ERH", \
                               abstract: "Assuming the ERH, we prove the existence of bound entangled NPT states.", \
                               identifier: "1108.1052", url: "http://arxiv.org/abs/1108.1052", \
                               submit_date: Time.now, update_date: Time.now)
  end

  subject { @paper }

  it { should respond_to(:title) }
  it { should respond_to(:authors) }
  it { should respond_to(:abstract) }
  it { should respond_to(:identifier) }
  it { should respond_to(:url) }
  it { should respond_to(:submit_date) }
  it { should respond_to(:update_date) }
  it { should respond_to(:scites) }
  it { should respond_to(:sciters) }
  it { should respond_to(:comments) }
  it { should respond_to(:feed) }
  it { should respond_to(:cross_lists) }
  it { should respond_to(:cross_listed_feeds) }

  it { should be_valid }

  describe "when title is not present" do
    before { @paper.title = " " }
    it { should_not be_valid }
  end

  describe "when abstract is not present" do
    before { @paper.abstract = " " }
    it { should_not be_valid }
  end

  describe "when identifier is not present" do
    before { @paper.identifier = " " }
    it { should_not be_valid }
  end

  describe "when url is not present" do
    before { @paper.url = " " }
    it { should_not be_valid }
  end

  describe "when submit_date is not present" do
    before { @paper.submit_date = " " }
    it { should_not be_valid }
  end

  describe "when update_date is not present" do
    before { @paper.update_date = " " }
    it { should_not be_valid }
  end

  describe "when update_date is older than submit_date" do
    before { @paper.update_date = @paper.submit_date - 1.day }
    it { should_not be_valid }
  end

  describe "when identifier is already taken" do
    before do
      paper_with_same_identifier = @paper.dup
      paper_with_same_identifier.save
    end

    it { should_not be_valid }
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
    let (:author1) { FactoryGirl.create(:authorship, paper: @paper, position: 0) }
    let (:author2) { FactoryGirl.create(:authorship, paper: @paper, position: 1) }

    it "should have the authors in the right order" do
      @paper.authors.should == [author1, author2]
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
