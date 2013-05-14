require 'spec_helper'

describe "Change Password" do
  let(:user) { FactoryGirl.create(:user) }

  before do
    sign_in(user)
    visit settings_password_path
  end

  describe "with correct previous password" do
    before do
      fill_in "current_password",  with: user.password
      fill_in "new_password", with: user.password+'new'
      fill_in "confirm_password",  with: user.password+'new'
      click_button "Save changes"
    end

    it { should have_selector('div.flash.success') }
    specify { user.reload.password.should == user.password+'new' }
  end
end
