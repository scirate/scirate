require "spec_helper"

describe UserMailer do

  subject { mail }

  describe 'signup confirmation email' do
    let(:user) { FactoryGirl.create(:user) }
    let(:mail) { UserMailer.signup_notification(user) }
 
    it 'renders the subject' do
      mail.subject.should == 'Welcome to Scirate!'
    end
  
    it 'renders the sender email' do
      mail.from.should == ['no-reply@scirate.com']
    end

    it 'has the right body content' do
      mail.body.encoded.should match("To activate your account, visit")
    end
 
    it 'renders the receiver email' do
       mail.to.should == [user.email]
    end

    it 'assigns @name' do
      mail.body.encoded.should match(user.name)
    end
 
    # #ensure that the @confirmation_url variable appears in the email body
    # it 'assigns @confirmation_url' do
    #   mail.body.encoded.should match("http://aplication_url/#{user.id}/confirmation")
    # end
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
