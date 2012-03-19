# == Schema Information
#
# Table name: papers
#
#  id           :integer         not null, primary key
#  title        :string(255)
#  authors      :text
#  abstract     :text
#  identifier   :string(255)
#  url          :string(255)
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#  pubdate      :date
#  updated_date :date
#

require 'spec_helper'

describe Paper do

  before do
    @paper = Paper.new(title: "On NPT Bound Entanglement and the ERH", \
                       authors: ["Some Guy, Ph.D.", "Some Other Guy"], \
                       abstract: "Assuming the ERH, we prove the existence of bound entangled NPT states.", \
                       identifier: "1108.1052", url: "http://arxiv.org/abs/1108.1052", \
                       pubdate: Time.now, updated_date: Time.now)
  end

  subject { @paper }

  it { should respond_to(:title) }
  it { should respond_to(:authors) }
  it { should respond_to(:abstract) }
  it { should respond_to(:identifier) }
  it { should respond_to(:url) }
  it { should respond_to(:pubdate) }
  it { should respond_to(:updated_date) }

  it { should be_valid }

  describe "when title is not present" do
    before { @paper.title = " " }
    it { should_not be_valid }
  end

  describe "when authors is not present" do
    before { @paper.authors = [] }
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

  describe "when pubdate is not present" do
    before { @paper.pubdate = " " }
    it { should_not be_valid }
  end

  describe "when updated_date is not present" do
    before { @paper.updated_date = " " }
    it { should_not be_valid }
  end

  describe "when updated_date is older than pubdate" do
    before { @paper.updated_date = @paper.pubdate - 1.day }
    it { should_not be_valid }
  end

  describe "when identifier is already taken" do
    before do
      paper_with_same_identifier = @paper.dup
      paper_with_same_identifier.save
    end

    it { should_not be_valid }
  end
end
