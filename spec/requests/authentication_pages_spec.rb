require 'spec_helper'

describe "google signup" do
  let(:mock_auth) { MockAuth.google }

  before do
    OmniAuth.config.mock_auth[:google_oauth2] = mock_auth
  end

  it "should allow signup via google" do
    find("a.btn-google").click # "Sign in with Google"
    #expect(page).to have_content "about to create a new SciRate account"
    #expect(page).to have_content "Google"
    #expect(page).to have_content mock_auth.info.email

    #click_button "Confirm And Create This Account"
    expect(page).to have_content "Sign out"

    user = User.where(email: mock_auth.info.email).first
    expect(user.active?).to be_truthy
  end

  it "should handle the case when email is taken" do
    FactoryGirl.create(:user, email: mock_auth.info.email)

    visit login_path
    click_link "Sign in with Google"
    p page.text
    expect(page).to have_error_message "please visit your settings page"
  end

  it "should allow login after account creation" do
    user = AuthLink.from_omniauth(mock_auth).create_user!

    visit login_path
    click_link "Sign in with Google"

    expect(page).to have_content "Sign out"
    expect(page).to have_content user.fullname
  end
end

describe "Authentication" do

  subject { page }

  describe "signin" do
    before { visit login_path }

    it "disallows invalid information" do
      click_button "Sign in"

      expect(page).to have_error_message "Invalid"
    end

    it "signs in and out correctly" do
      user = FactoryGirl.create(:user)
      sign_in(user)

      expect(page).to have_title "Home feed"
      expect(page).to have_link('Profile', href: user_path(user))
      expect(page).to have_link('Settings', href: settings_path)
      expect(page).to have_link('Sign out', href: logout_path)
      expect(page).to_not have_link('Sign in', href: login_path)

      sign_out
      expect(page).to have_title('Top arXiv papers')
      expect(page).to_not have_link('Sign out', href: logout_path)
      expect(page).to_not have_link('Profile', href: user_path(user))
      expect(page).to_not have_link('Settings', href: settings_path)
    end
  end

  describe "authorization" do
    describe "for non-signed-in users" do
      let(:user) { FactoryGirl.create(:user) }

      describe "in the Users controller" do

        describe "visiting the edit page" do
          before { visit admin_edit_user_path(user) }
          it { is_expected.to have_title 'Sign in' }
        end

        describe "submitting to the update action" do
          before { post admin_update_user_path(user) }
          specify { expect(response).to redirect_to(login_path) }
        end
      end
    end

    describe "as wrong user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@example.com") }
      before { sign_in user }

      describe "visiting Users#edit page" do
        before { visit admin_edit_user_path(wrong_user) }

        it { is_expected.to have_title '' }
      end

      describe "submitting to the Users#update action" do
        before do
          post admin_update_user_path(wrong_user)
        end

        specify { expect(response).to redirect_to(root_path) }
      end
    end

    describe "as signed-in user" do
      let(:user) { FactoryGirl.create(:user) }
      before { sign_in user }

      describe "submitting a GET request to the Users#new action" do
        before do
          get signup_path
        end

        specify { expect(response).to redirect_to(root_path) }
      end

      describe "submitting a POST request to the Users#create action" do
        before do
          post signup_path
        end

        specify { expect(response).to redirect_to(root_path) }
      end
    end

    describe "for non-signed-in users" do
      let(:user) { FactoryGirl.create(:user) }
      let(:paper){ FactoryFirl.create(:paper) }

      describe "when attempting to visit a protected page" do
        before do
          visit admin_edit_user_path(user)
          fill_in "Email",    with: user.email
          fill_in "Password", with: user.password
          click_button "Sign in"
        end

#        describe "after signing in" do
#          it "should render the desired protected page" do
#            page.should have_title 'Edit user'
#          end
#        end

        describe "when signing in again" do
          before { sign_in user }

          it "renders the home feed" do
            expect(page).to have_title "Home feed"
          end
        end
      end
    end
  end
end
