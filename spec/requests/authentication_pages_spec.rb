require 'spec_helper'

describe "Authentication" do

  subject { page }

  describe "signin" do
    before { visit signin_path }

    describe "with invalid information" do
      before { click_button "Sign in" }

      it { should have_error_message 'Invalid' }
    end

    describe "with valid information" do
      let(:user) { FactoryGirl.create(:user) }
      before { sign_in(user) }

      it { should have_title user.name }
      it { should have_link('Profile', href: user_path(user)) }
      it { should have_link('Settings', href: settings_path) }
      it { should have_link('Sign out', href: signout_path) }
      it { should_not have_link('Sign in', href: signin_path) }

      describe "followed by signout" do
        before { signout }
        it { should have_link('sign in', href: signin_path) }
        it { should_not have_link('Sign out', href: signout_path) }
        it { should_not have_link('Profile', href: user_path(user)) }
        it { should_not have_link('Settings', href: edit_user_path(user)) }
        it { should_not have_link('Subscriptions', href: subscriptions_user_path(user)) }
      end
    end
  end

  describe "authorization" do

    describe "for non-signed-in users" do
      let(:user) { FactoryGirl.create(:user) }

      describe "in the Users controller" do

        describe "visiting the edit page" do
          before { visit edit_user_path(user) }
          it { should have_title 'Sign in' }
        end

        describe "submitting to the update action" do
          before { put user_path(user) }
          specify { response.should redirect_to(signin_path) }
        end
      end
    end

    describe "as wrong user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@example.com") }
      before { sign_in user }

      describe "visiting Users#edit page" do
        before { visit edit_user_path(wrong_user) }

        it { should have_title '' }
      end

      describe "submitting a PUT request to the Users#update action" do
        before do
          put user_path(wrong_user)
        end

        specify { response.should redirect_to(root_path) }
      end
    end

    describe "as signed-in user" do
      let(:user) { FactoryGirl.create(:user) }
      before { sign_in user }

      describe "submitting a GET request to the Users#new action" do
        before do
          get new_user_path
        end

        specify { response.should redirect_to(root_path) }
      end

      describe "submitting a POST request to the Users#create action" do
        before do
          post users_path
        end

        specify { response.should redirect_to(root_path) }
      end
    end


    describe "for non-signed-in users" do
      let(:user) { FactoryGirl.create(:user) }
      let(:paper){ FactoryFirl.create(:paper) }

      describe "when attempting to visit a protected page" do
        before do
          visit edit_user_path(user)
          fill_in "Email",    with: user.email
          fill_in "Password", with: user.password
          click_button "Sign in"
        end

        describe "after signing in" do

          it "should render the desired protected page" do
            page.should have_title 'Edit user'
          end
        end

        describe "when signing in again" do
          before { sign_in user }

          it "should render the default (profile) page" do
            page.should have_title user.name
          end
        end
      end
    end
  end
end
