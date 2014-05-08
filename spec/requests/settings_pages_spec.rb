require 'spec_helper'

describe "Settings page" do
  before do
    @user = FactoryGirl.create(:user)
    sign_in @user
    visit settings_path
  end

  it "has the right settings fields" do
    expect(page).to have_link('change', href: 'http://gravatar.com/emails')
    expect(page).to have_field "Name", with: @user.fullname
    expect(page).to have_field "Email", with: @user.email
  end

  it "doesn't allow use of reserved usernames" do
    fill_in "Username", with: "arxiv"
    click_button "Save changes"

    expect(page).to have_error_message "Username is already taken"
  end

  it "changes name, username and email" do
    new_name = "New Name"
    new_username = "new_name"
    new_email = "new@example.com"

    fill_in "Name", with: new_name
    fill_in "Username", with: new_username
    fill_in "Email", with: new_email
    click_button "Save changes"

    expect(page).to have_success_message

    @user.reload
    expect(@user.fullname).to eq new_name
    expect(@user.username).to eq new_username
    expect(@user.email).to eq new_email
  end

  it "emails about address changes" do
    new_email = "new@example.com"
    fill_in "Email", with: new_email
    click_button "Save changes"

    expect(last_email).to_not be_nil
    expect(last_email.to).to include(@user.email)
  end

  it "doesn't email without address changes" do
    new_name = "New Name"
    fill_in "Name", with: new_name
    click_button "Save changes"

    expect(last_email).to be_nil
  end
end

describe "Linking to Google" do
  before do
    OmniAuth.config.mock_auth[:google_oauth2] = MockAuth.google
  end

  context "with no existing auth link" do
    let(:user) { FactoryGirl.create(:user) }

    before do
      sign_in user
      visit settings_path
      click_link "Enable Google login"
    end

    it "links successfully" do
      expect(page).to have_success_message
      expect(page).to have_content "Connected to Google"
    end
  end

  context "with a mismatched auth link" do
    let(:user) { FactoryGirl.create(:user) }
    let(:link) { AuthLink.from_omniauth(MockAuth.google) }

    before do
      link.create_user!
      sign_in user
      visit settings_path
      click_link "Enable Google login"
    end

    it "tells the user to disconnect the other link" do
      expect(page).to have_error_message "already linked to another user"
      expect(page).to_not have_content "Connected to Google"
    end
  end
end

describe "Unlinking from Google" do
  let(:user) { google_user }

  context "with no password" do
    before do
      sign_up_with_google
      visit settings_path
      click_link "disconnect"
    end

    it "tells the user to add a password" do
      expect(page).to have_error_message "add a password"
      expect(page).to have_content "Connected to Google"
    end
  end

  context "with password" do
    before do
      sign_up_with_google

      visit settings_password_path
      fill_in "new_password", with: 'newpass'
      fill_in 'confirm_password', with: 'newpass'
      click_button "Save changes"

      visit settings_path
      click_link "disconnect"
    end

    it "disconnects successfully" do
      expect(page).to have_success_message "disconnected"
      expect(page).to_not have_content "Connected to Google"
    end
  end
end
