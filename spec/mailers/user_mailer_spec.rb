require "spec_helper"

describe UserMailer do

  subject { mail }

  describe 'signup confirmation email' do
    let(:user) { FactoryGirl.create(:user, confirmation_token: "some_token") }
    let(:mail) { UserMailer.signup_confirmation(user) }
 
    it 'renders the subject' do
      mail.subject.should == 'Welcome to Scirate!'
    end
  
    it 'renders the sender email' do
      mail.from.should == ['no-reply@scirate.com']
    end

    it 'has the right body content' do
      mail.body.encoded.should match("Welcome to Scirate!  To activate your account, click the URL below.")
    end
 
    it 'renders the receiver email' do
       mail.to.should == [user.email]
    end

    it 'assigns @name' do
      mail.body.encoded.should match(user.name)
    end
 
    it 'includes the right url' do
      mail.body.encoded.should match( activate_user_url(id: user.id, confirmation_token: user.confirmation_token) )
    end
  end

  describe "password reset email" do
    let(:user) { FactoryGirl.create(:user, 
                                    password_reset_token: "asdf1234" ) }
    let(:mail) { UserMailer.password_reset(user) }
 
    it 'has the right subject' do
      mail.subject.should == "Password Reset"
    end
  
    it 'has the right sender' do
      mail.from.should == ['no-reply@scirate.com']
    end

    it 'has the right body content' do
      mail.body.encoded.should match("To reset your password, click the URL below.")
    end
 
    it 'renders the receiver email' do
       mail.to.should == [user.email]
    end

    it 'assigns @name' do
      mail.body.encoded.should match(user.name)
    end
 
    it 'assigns the right url' do
      mail.body.encoded.should match( edit_password_reset_url(user.password_reset_token))
    end
  end
end
