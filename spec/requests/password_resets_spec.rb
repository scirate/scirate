require "spec_helper"

describe "password resets" do

  subject { page }

  describe "emails user when requesting password reset" do
    let(:user) { FactoryGirl.create(:user) }

    before do
      visit signin_path
      click_link "password"
      fill_in "Email", :with => user.email
      click_button "Reset Password"
    end

    it { should have_title "" }
    it { should have_content("Email sent") }

    it "should send the email" do
      last_email.to.should include(user.email)
    end
  end

  describe "does not email invalid user when requesting password reset" do
    let(:user) { FactoryGirl.create(:user) } 
    
    before do
      visit signin_path
      click_link "password"
      fill_in "Email", :with => "bogus@bogus.bogus"
      click_button "Reset Password"
    end
    
    it { should have_title "" }
    it { should have_content("Email sent") }
  
    it "should not send the email" do
      last_email.should be_nil
    end
  end

  describe "updates the user password when confirmation matches" do
    let(:user) { FactoryGirl.create(:user, 
                                    :password_reset_token => "asdf1234zxcv", 
                                    :password_reset_sent_at => 1.hour.ago) }
    
    describe "with invalid information" do
      before do 
        visit edit_password_reset_path(user.password_reset_token)
        fill_in "Password", :with => "foobar"
        click_button "Update Password"
      end
      
      it { should have_content("Password doesn't match confirmation") }
    end

    describe "with valid information" do      
      before do
        visit edit_password_reset_path(user.password_reset_token)
        fill_in "Password", :with => "foobar"
        fill_in "Password confirmation", :with => "foobar"
        click_button "Update Password"
      end
    
      it { should have_content("Password has been reset") }
    end
  end

  describe "when the password token has expired" do
    let(:user) { FactoryGirl.create(:user, 
                                    :password_reset_token => "asdf1234zxcv", 
                                    :password_reset_sent_at => 5.hour.ago) }

    before do
      visit edit_password_reset_path(user.password_reset_token)
      fill_in "Password", :with => "foobar"
      fill_in "Password confirmation", :with => "foobar"
      click_button "Update Password"
    end
      
    it { should have_content("Password reset has expired") }
  end

  describe "when the password token is invalid" do
    before do
      visit edit_password_reset_path("invalid")
    end
    
    it { should have_title "" }
    it { should have_content("Password reset has already been used or is invalid!") }
  end
end
