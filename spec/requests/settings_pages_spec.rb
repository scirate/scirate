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

    expect(page).to have_selector('.alert-success')

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

  it "allows linking to google" do
  end
end
