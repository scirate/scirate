# == Schema Information
#
# Table name: papers
#
#  id             :integer          not null, primary key
#  uid            :string(255)      not null
#  submitter      :string(255)      not null
#  title          :string(255)      not null
#  abstract       :text             not null
#  comments       :text
#  msc_class      :string(255)
#  report_no      :string(255)
#  journal_ref    :string(255)
#  doi            :string(255)
#  proxy          :string(255)
#  license        :string(255)
#  submit_date    :datetime         not null
#  update_date    :datetime         not null
#  abs_url        :string(255)      not null
#  pdf_url        :string(255)      not null
#  delta          :boolean          default(TRUE), not null
#  created_at     :datetime
#  updated_at     :datetime
#  scites_count   :integer          default(0), not null
#  comments_count :integer          default(0), not null
#

require 'spec_helper'

describe Paper do
  before do
    @feed = FactoryGirl.create(:feed)
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
