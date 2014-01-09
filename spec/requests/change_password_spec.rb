require 'spec_helper'

describe "Change Password" do
  subject { page }
  let(:user) { FactoryGirl.create(:user) }

  before do
    sign_in(user)
    visit settings_password_path
  end

  describe "with incorrect previous password" do
    before do
      fill_in "current_password",  with: 'password'
      fill_in "new_password", with: 'iamsleethacker'
      fill_in "confirm_password",  with: 'iamsleethacker'
      click_button "Save changes"
    end

    it { should have_error_message }
    specify { user.reload.authenticate('iamsleethacker').should be_false }
  end

  describe "with correct previous password" do
    before do
      fill_in "current_password",  with: user.password
      fill_in "new_password", with: user.password+'new'
      fill_in "confirm_password",  with: user.password+'new'
      click_button "Save changes"
    end

    it { should have_selector('.alert-success') }
    specify { user.reload.authenticate(user.password+'new').should be_true }

    it "should send an email notification" do
      last_email.should_not be_nil
      last_email.to.should include(user.email)
      last_email.subject.should include("password has been changed")
    end
  end
end
