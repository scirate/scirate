require 'spec_helper'

describe "profile page" do
  before(:all) do
    @user = FactoryGirl.create(:user)
  end

  it "displays profile if you're logged in" do
    other_user = FactoryGirl.create(:user)
    sign_in(other_user)
    visit user_path(@user)
    expect(page).to have_heading @user.fullname
    expect(page).to have_title @user.fullname
  end

  it "displays profile if you're logged out" do
    visit user_path(@user)
    expect(page).to have_heading @user.fullname
    expect(page).to have_title @user.fullname
  end

  it "updates the activity feed when a comment is deleted" do
    comment = FactoryGirl.create(:comment, content: "good comment", user: @user)
    comment2 = FactoryGirl.create(:comment, content: "kinda sucky comment", user: @user)
    visit user_path(@user)
    expect(page).to have_selector('.comment', text: comment.content)
    expect(page).to have_content(comment2.content)
    comment2.soft_delete!(@user.id)
    visit user_path(@user)
    expect(page).to have_selector('.comment', text: comment.content)
    expect(page).to_not have_content(comment2.content)
  end
end

describe "signup page" do
  before { visit signup_path }

  it "shows the signup page" do
    expect(page).to have_heading "Join SciRate"
    expect(page).to have_title "Join SciRate"
  end

  it "errors on invalid details" do
    expect { click_button "Sign up" }.to_not change(User, :count)

    expect(page).to have_title "Join SciRate"
    expect(page).to have_error_message
  end

  # This test doesn't work any more given that we've added the CAPTCHA.
  # it "allows proper signup" do
  #   fullname = "Example User"
  #   email = "user@example.com"
  #   password = "foobar"

  #   fill_in "Name", with: fullname
  #   fill_in "Email", with: email
  #   fill_in "user_password", with: password

  #   expect { click_button "Sign up" }.to change(User, :count).by(1)

  #   user = User.find_by_email(email)
  #   expect(user.fullname).to eq(fullname)

  #   expect(page).to have_title "Home feed"

  #   # Test presence of welcome banner
  #   expect(page).to have_content "Welcome to SciRate!"
  #   expect(page).to have_content user.email

  #   # Make sure it sent a confirmation email
  #   expect(last_email.to).to include(user.email)
  # end
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

      expect(page).to have_content("Your account has been activated")
    end
  end

  context "with invalid confirmation" do
    it "doesn't activate the user" do
      visit activate_user_path(@user.id, "bogus")
      @user.reload
      expect(@user.active).to be(false)

      expect(page).to have_content("link is invalid")
    end
  end

  context "with expired confirmation" do
    before do
      @user.confirmation_sent_at = 3.days.ago
      @user.save!
    end

    it "doesn't activate and sends a new email" do
      expect {
        visit activate_user_path(@user.id, @user.confirmation_token)
      }.to(
        have_enqueued_job.on_queue('mailers').with(
          "UserMailer",
          "signup_confirmation",
          "deliver_now",
          @user
        )
      )

      @user.reload

      expect(@user.active).to be(false)

      expect(page).to have_content("link has expired")
      expect(page).to have_content("email has been sent")
    end
  end

  context "with already used confirmation" do
    it "shows an error" do
      visit activate_user_path(@user.id, @user.confirmation_token)
      visit activate_user_path(@user.id, @user.confirmation_token)

      expect(page).to have_content("link is invalid")
    end
  end
end
