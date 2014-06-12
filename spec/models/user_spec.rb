# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  fullname               :text
#  email                  :text
#  remember_token         :text
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  password_digest        :text
#  scites_count           :integer          default(0)
#  password_reset_token   :text
#  password_reset_sent_at :datetime
#  confirmation_token     :text
#  active                 :boolean          default(FALSE)
#  comments_count         :integer          default(0)
#  confirmation_sent_at   :datetime
#  subscriptions_count    :integer          default(0)
#  expand_abstracts       :boolean          default(FALSE)
#  account_status         :text             default("user")
#  username               :text             not null
#

require 'spec_helper'

describe User do

  let(:user) { FactoryGirl.create(:user) }

  subject { user }

  it { should validate_presence_of(:fullname) }
  it { should ensure_length_of(:fullname).is_at_most(50) }
  it { should validate_presence_of(:email) }
  it { should validate_uniqueness_of(:email) }

  describe "when email format is invalid" do
    invalid_addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
    invalid_addresses.each do |invalid_address|
      before { user.email = invalid_address }
      it { should_not be_valid }
    end
  end

  describe "when email format is valid" do
    valid_addresses = %w[user@foo.com A_USER@f.b.org frst.lst@foo.jp a+b@baz.cn]
    valid_addresses.each do |valid_address|
      before { user.email = valid_address }
      it { should be_valid }
    end
  end

  describe "when password is not present" do
    before { user.password = user.password_confirmation = " " }
    it { should_not be_valid }
  end

  describe "when password doesn't match confirmation" do
    before { user.password_confirmation = "mismatch" }
    it { should_not be_valid }
  end

  describe "with a password that's too short" do
    before { user.password = user.password_confirmation = "a" * 5 }
    it { should_not be_valid }
  end

  describe "return value of authenticate method" do
    before { user.save }
    let(:found_user) { User.find_by_email(user.email) }

    describe "with valid password" do
      it { should == found_user.authenticate(user.password) }
    end

    describe "with invalid password" do
      let(:user_for_invalid_password) { found_user.authenticate("invalid") }

      it { should_not == user_for_invalid_password }
      specify { user_for_invalid_password.should be_false }
    end
  end

  describe "remember token" do
    before { user.save }
    specify { expect(user.remember_token).to_not be_blank }
  end

  describe "comments" do
    let (:paper) { FactoryGirl.create(:paper) }

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

    it "should have the right comments in the right order" do
      user.comments.should == [new_comment, med_comment, old_comment]
    end
  end

  describe "subscribing to a feed" do
    let (:feed) { FactoryGirl.create(:feed) }
    before { user.subscribe!(feed) }
    specify { expect(feed.users.pluck(:id)).to include(user.id) }

    describe "and unsubscribing" do
      before { user.unsubscribe!(feed) }
      specify { expect(feed.users.pluck(:id)).to_not include(user.id) }
    end
  end

  describe "User#activity_feed" do
    let(:activities) { user.activity_feed }

    it "adds a default initial activity" do
      expect(activities[-1].event).to eq 'signup'
      expect(activities[-1].created_at).to eq user.created_at
    end
  end
end
