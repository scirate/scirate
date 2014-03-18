require 'spec_helper'

describe "profile page" do
  before(:all) do
    @user = FactoryGirl.create(:user)
  end

  it "should display profile if you're logged in" do
    other_user = FactoryGirl.create(:user)
    sign_in(other_user)
    visit user_path(@user)
    page.should have_heading @user.fullname
    page.should have_title @user.fullname
  end

  it "should display profile if you're logged out" do
    visit user_path(@user)
    page.should have_heading @user.fullname
    page.should have_title @user.fullname
  end
end

describe "signup page" do
  before { visit signup_path }

  it "shows the signup page" do
    page.should have_heading "Join SciRate"
    page.should have_title "Join SciRate"
  end

  it "errors on invalid details" do
    expect { click_button "Sign up" }.not_to change(User, :count)

    page.should have_title "Join SciRate"
    page.should have_error_message
  end

  it "allows proper signup" do
    fullname = "Example User"
    email = "user@example.com"
    password = "foobar"

    fill_in "Name", with: fullname
    fill_in "Email", with: email
    fill_in "user_password", with: password

    expect { click_button "Sign up" }.to change(User, :count).by(1)

    user = User.find_by_email(email)
    user.fullname.should == fullname

    page.should have_title "Home feed"
    
    # Test presence of welcome banner
    page.should have_content "Welcome to SciRate!"
    page.should have_content user.email

    # Make sure it sent a confirmation email
    last_email.to.should include(user.email)
  end
end

describe "email confirmation" do
  before do
    @user = FactoryGirl.create(:user,
                               active: false,
                               confirmation_token: "i-am-a-token",
                               confirmation_sent_at: 2.hours.ago)


  end

  context "with valid confirmation" do
    it "activates the user" do
      expect do
        visit activate_user_path(@user.id, @user.confirmation_token)
        @user.reload
      end.to change(@user, :active).to(true)

      page.should have_content("Your account has been activated")
    end
  end

  context "with invalid confirmation" do
    it "doesn't activate the user" do
      expect do
        visit activate_user_path(@user.id, "bogus")
        @user.reload
      end.not_to change(@user, :active).to(true)

      page.should have_content("link is invalid")
    end
  end

  context "with expired confirmation" do
    before do
      @user.confirmation_sent_at = 3.days.ago
      @user.save!
    end

    it "doesn't activate and sends a new email" do
      expect do
        visit activate_user_path(@user.id, @user.confirmation_token)
        @user.reload
      end.not_to change(@user, :active).to(true)

      page.should have_content("link has expired")
      page.should have_content("email has been sent")

      @user.reload
      last_email.to.should include(@user.email)
      last_email.body.should include(@user.confirmation_token)
    end
  end

  context "with already used confirmation" do
    it "shows an error" do
      visit activate_user_path(@user.id, @user.confirmation_token)
      visit activate_user_path(@user.id, @user.confirmation_token)

      page.should have_content("link is invalid")
    end
  end
end

describe "settings" do
  before do
    @user = FactoryGirl.create(:user)
    sign_in @user
    visit settings_path
  end

  it "has the right settings fields" do
    page.should have_link('change', href: 'http://gravatar.com/emails')
    page.should have_field "Name", with: @user.fullname
    page.should have_field "Email", with: @user.email
  end

  it "doesn't allow use of reserved usernames" do
    fill_in "Username", with: "arxiv"
    click_button "Save changes"

    page.should have_error_message "Username is already taken"
  end

  it "changes name, username and email" do
    new_name = "New Name"
    new_username = "new_name"
    new_email = "new@example.com"

    fill_in "Name", with: new_name
    fill_in "Username", with: new_username
    fill_in "Email", with: new_email
    click_button "Save changes"

    page.should have_selector('.alert-success')
    @user.reload
    @user.fullname.should == new_name
    @user.username.should == new_username
    @user.email.should == new_email
  end

  it "emails about address changes" do
    new_email = "new@example.com"
    fill_in "Email", with: new_email
    click_button "Save changes"

    last_email.should_not be_nil
    last_email.to.should include(@user.email)
  end

  it "doesn't email without address changes" do
    new_name = "New Name"
    fill_in "Name", with: new_name
    click_button "Save changes"

    last_email.should be_nil
  end
end
