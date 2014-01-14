# == Schema Information
#
# Table name: users
#
#  id                     :integer         primary key
#  name                   :string(255)
#  email                  :string(255)
#  remember_token         :string(255)
#  created_at             :timestamp       not null
#  updated_at             :timestamp       not null
#  password_digest        :string(255)
#  scites_count           :integer         default(0)
#  password_reset_token   :string(255)
#  password_reset_sent_at :timestamp
#  confirmation_token     :string(255)
#  active                 :boolean         default(FALSE)
#  comments_count         :integer         default(0)
#  confirmation_sent_at   :timestamp
#  subscriptions_count    :integer         default(0)
#

require 'spec_helper'

describe User do

  before do
    @user = User.new(name: "Example User", username: "example",
                     email: "user@example.com", 
                     password: "foobar", password_confirmation: "foobar")
  end

  subject { @user }

  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:remember_token) }
  it { should respond_to(:authenticate) }
  it { should respond_to(:scites) }
  it { should respond_to(:scited_papers) }
  it { should respond_to(:scited?) }
  it { should respond_to(:scite!) }
  it { should respond_to(:unscite!) }
  it { should respond_to(:subscriptions) }
  it { should respond_to(:subscribed?) }
  it { should respond_to(:subscribe!) }
  it { should respond_to(:unsubscribe!) }
  it { should respond_to(:feeds) }
  it { should respond_to(:comments) }
  it { should respond_to(:password_reset_token) }
  it { should respond_to(:password_reset_sent_at) }
  it { should respond_to(:confirmation_token) }
  it { should respond_to(:confirmation_sent_at) }

  it { should be_valid }

  describe "when name is not present" do
    before { @user.name = " " }
    it { should_not be_valid }
  end

  describe "when email is not present" do
    before { @user.email = " " }
    it { should_not be_valid }
  end

  describe "when name is too long" do
    before { @user.name = "a" * 51 }
    it { should_not be_valid }
  end

  describe "when email format is invalid" do
    invalid_addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
    invalid_addresses.each do |invalid_address|
      before { @user.email = invalid_address }
      it { should_not be_valid }
    end
  end

  describe "when email format is valid" do
    valid_addresses = %w[user@foo.com A_USER@f.b.org frst.lst@foo.jp a+b@baz.cn]
    valid_addresses.each do |valid_address|
      before { @user.email = valid_address }
      it { should be_valid }
    end
  end

  describe "when email address is already taken" do
    before do
      user_with_same_email = @user.dup
      user_with_same_email.save
    end

    it { should_not be_valid }
  end

  describe "when email address is already taken" do
    before do
      user_with_same_email = @user.dup
      user_with_same_email.email = @user.email.upcase
      user_with_same_email.save
    end

    it { should_not be_valid }
  end

  describe "when password is not present" do
    before { @user.password = @user.password_confirmation = " " }
    it { should_not be_valid }
  end
  
  describe "when password doesn't match confirmation" do
    before { @user.password_confirmation = "mismatch" }
    it { should_not be_valid }
  end

  describe "with a password that's too short" do
    before { @user.password = @user.password_confirmation = "a" * 5 }
    it { should be_invalid }
  end

  describe "return value of authenticate method" do
    before { @user.save }
    let(:found_user) { User.find_by_email(@user.email) }

    describe "with valid password" do
      it { should == found_user.authenticate(@user.password) }
    end

    describe "with invalid password" do
      let(:user_for_invalid_password) { found_user.authenticate("invalid") }

      it { should_not == user_for_invalid_password }
      specify { user_for_invalid_password.should be_false }
    end
  end

  describe "remember token" do
    before { @user.save }
    its(:remember_token) { should_not be_blank }
  end

  describe "sciting" do
    let (:paper) { FactoryGirl.create(:paper) }
    before do
      @user.save
      @user.scite!(paper)
    end

    it { should be_scited(paper) }
    its(:scited_papers) { should include(paper) }

    describe "and unsciting" do
      before { @user.unscite!(paper) }
      its(:scited_papers) { should_not include(paper) }
    end
  end

  describe "comments" do
    let (:paper) { FactoryGirl.create(:paper) }
    
    before { @user.save }
    let!(:old_comment) do
      FactoryGirl.create(:comment, 
                         user: @user, paper: paper, created_at: 1.day.ago)
    end
    let!(:new_comment) do
      FactoryGirl.create(:comment, 
                         user: @user, paper: paper, created_at: 1.minute.ago)
    end
    let!(:med_comment) do
      FactoryGirl.create(:comment, 
                         user: @user, paper: paper, created_at: 1.hour.ago)
    end

    it "should have the right comments in the right order" do
      @user.comments.should == [new_comment, med_comment, old_comment]
    end
  end

  describe "subscribing to a feed" do
    let (:feed) { FactoryGirl.create(:feed) }
    before do
      @user.save
      @user.subscribe!(feed)
    end

    it { should be_subscribed(feed) }
    its(:feeds) { should include(feed) }

    describe "and unsubscribing" do
      before { @user.unsubscribe!(feed) }
      its(:feeds) { should_not include(feed) }
    end
  end
end
