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
#  versions_count  :integer          default(1), not null
#

require 'spec_helper'

describe Paper do
  let(:paper) { FactoryGirl.create(:paper) }

  subject { paper }

  it { is_expected.to respond_to(:title) }
  it { is_expected.to respond_to(:authors) }
  it { is_expected.to respond_to(:abstract) }
  it { is_expected.to respond_to(:uid) }
  it { is_expected.to respond_to(:abs_url) }
  it { is_expected.to respond_to(:pdf_url) }
  it { is_expected.to respond_to(:submit_date) }
  it { is_expected.to respond_to(:update_date) }
  it { is_expected.to respond_to(:scites) }
  it { is_expected.to respond_to(:sciters) }
  it { is_expected.to respond_to(:comments) }
  it { is_expected.to respond_to(:categories) }

  it { is_expected.to validate_uniqueness_of(:uid) }
  it { is_expected.to be_valid }

  describe "#to_bibtex" do
    let(:paper) do
      paper = FactoryGirl.create(:paper_with_versions,
        author_str: "Susanta K. Khan and Madhumangal Pal",
        title: "Interval-Valued Intuitionistic Fuzzy Matrices",
        pubdate: "2014-05-12 01:00:00 UTC",
        uid: "1404.6949",
        journal_ref: "Notes on Intuitionistic Fuzzy Sets, 11(1) (2005)16-27"
      )

      FactoryGirl.create(:author, fullname: "Susanta K. Khan", paper_uid: paper.uid)
      FactoryGirl.create(:author, fullname: "Madhumangal Pal", paper_uid: paper.uid)

      paper
    end

    it "generates bibtex correctly" do
     expect(paper.to_bibtex).to eq %Q{@misc{1404.6949,
  author = {Susanta K.~Khan and Madhumangal Pal},
  title = {{I}nterval-{V}alued {I}ntuitionistic {F}uzzy {M}atrices},
  year = {2014},
  eprint = {1404.6949},
  howpublished = {Notes on Intuitionistic Fuzzy Sets, 11(1) (2005)16-27},
  note = {arXiv:1404.6949v3}
}}
    end
  end

  describe "sciting" do
    let (:user) { FactoryGirl.create(:user) }
    before { user.scite!(paper) }

    it "scites the paper" do
      expect(paper.sciters.pluck(:id)).to include(user.id)
    end
  end

  describe "authors" do
    let (:author1) { FactoryGirl.create(:author, paper: paper, position: 0) }
    let (:author2) { FactoryGirl.create(:author, paper: paper, position: 1) }

    it "should have the authors in the right order" do
      expect(paper.reload.authors).to eq [author1, author2]
    end
  end

  describe "comments" do
    let (:user) { FactoryGirl.create(:user) }
    before { user.save }

    let!(:old_comment) do
      FactoryGirl.create(:comment,
                         user: user, paper: paper, created_at: 1.day.ago)
    end
    let!(:new_comment) do
      FactoryGirl.create(:comment,
                         user: user, paper: paper, created_at: 1.minute.ago)
    end
    let!(:med_comment) do
      FactoryGirl.create(:comment,
                         user: user, paper: paper, created_at: 1.hour.ago)
    end

    it "has the right comments in the right order" do
      expect(paper.comments).to eq [old_comment, med_comment, new_comment]
    end
  end
end
