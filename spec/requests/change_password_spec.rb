require 'spec_helper'

describe "Password Settings" do
  subject { page }
  context "as user signed up with google" do
    let(:user) { google_user }

    before do
      sign_in_with_google
      visit settings_password_path

      expect(page).to have_content "does not require a password"
      fill_in "new_password", with: 'newpass'
      fill_in "confirm_password", with: 'newpass'
      click_button "Save changes"
    end

    it "changes the password" do
      expect(page).to have_selector('.alert-success')
      expect(user.reload.authenticate('newpass')).to be_true
    end
  end

  context "as a normal user" do
    let(:user) { FactoryGirl.create(:user) }

    before do
      sign_in(user)
      visit settings_password_path
    end

    context "with incorrect previous password" do
      before do
        fill_in "current_password", with: 'password'
        fill_in "new_password", with: 'iamsleethacker'
        fill_in "confirm_password", with: 'iamsleethacker'
        click_button "Save changes"
      end

      it "throws an error" do
        expect(page).to have_error_message
        expect(user.reload.authenticate('iamsleethacker')).to be_false
      end
    end

    context "with correct previous password" do
      before do
        fill_in "current_password",  with: user.password
        fill_in "new_password", with: user.password+'new'
        fill_in "confirm_password",  with: user.password+'new'
        click_button "Save changes"
      end

      it "changes the password" do
        expect(page).to have_selector('.alert-success')
        expect(user.reload.authenticate(user.password+'new')).to be_true
      end

      it "sends an email notification" do
        expect(last_email).to_not be_nil
        expect(last_email.to).to include(user.email)
        expect(last_email.subject).to include("password has been changed")
      end
    end
  end
end
