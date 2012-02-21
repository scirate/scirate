require 'spec_helper'

describe "User pages" do

  subject { page }

  # describe "profile page" do
  #   let(:user) { FactoryGirl.create(:user) }

  #   before { visit user_path(user) }

  #   it { should have_heading user.name }
  #   it { should have_title user.name }
  # end

  describe "signup page" do
    before { visit signup_path }

    it { should have_heading 'Sign up' }
    it { should have_title 'Sign up' }
  end

  # describe "signup" do

  #   before { visit signup_path }

  #   describe "with invalid information" do
  #     it "should not create a user" do
  #       expect { signup }.not_to change(User, :count)
  #     end
  #   end

  #   describe "error messages" do
  #     before { signup }
      
  #     let(:error) { 'errors prohibited this user from being saved' }
      
  #     it { should have_title 'Sign up' }
  #     it { should have_content(error) }
  #   end

  #   describe "with valid information" do
  #     it "should create a user" do
  #       expect { valid_signup }.to change(User, :count).by(1)
  #     end

  #     describe "after saving the user" do
  #       before { valid_signup(email: 'test@example.com') }
  #       let(:user) { User.find_by_email('test@example.com') }
        
  #       it { should have_title user.name }
  #       it { should have_success_message 'Welcome' }
  #       it { should have_link('Sign out') }
  #     end
  #   end
  # end
  
  # describe "edit" do
  #   let(:user) { FactoryGirl.create(:user) }
  #   before do
  #     sign_in user
  #     visit edit_user_path(user)
  #   end

  #   describe "page" do
  #     it { should have_heading "Edit user" }
  #     it { should have_title "Edit user" }
  #     it { should have_link('change', href: 'http://gravatar.com/emails') }
  #   end

  #   describe "with invalid information" do
  #     let(:error) { '1 error prohibited this user from being saved' }
  #     before { update }

  #     it { should have_content(error) }
  #  end
  
  #   describe "with valid information" do
  #     let(:user)      { FactoryGirl.create(:user) }
  #     let(:new_name)  { "New Name" }
  #     let(:new_email) { "new@example.com" }
  #     before do
  #       fill_in "Name",         with: new_name
  #       fill_in "Email",        with: new_email
  #       fill_in "Password",     with: user.password
  #       fill_in "Confirmation", with: user.password
  #       click_button "Update"
  #     end

  #     it { should have_selector('title', text: new_name) }
  #     it { should have_selector('div.flash.success') }
  #     specify { user.reload.name.should  == new_name }
  #     specify { user.reload.email.should == new_email }
  #   end
  # end
end
