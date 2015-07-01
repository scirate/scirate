require "spec_helper"

describe UserMailer do
  subject { mail }

  describe 'signup confirmation email' do
    let(:user) { FactoryGirl.create(:user, confirmation_token: "some_token") }
    let(:mail) { UserMailer.signup_confirmation(user) }

    it 'renders the subject' do
      expect(mail.subject).to eq('Welcome to SciRate!')
    end

    it 'renders the sender email' do
      expect(mail.from).to eq(['notifications@scirate.com'])
    end

    it 'has the right body content' do
      expect(mail.body.encoded).to match("Welcome to SciRate!  To activate your account, click the URL below.")
    end

    it 'renders the receiver email' do
       expect(mail.to).to eq([user.email])
    end

    it 'assigns @name' do
      expect(mail.body.encoded).to match(user.fullname)
    end

    it 'includes the right url' do
      expect(mail.body.encoded).to match( activate_user_url(id: user.id, confirmation_token: user.confirmation_token) )
    end
  end

  describe "password reset email" do
    let(:user) { FactoryGirl.create(:user,
                                    password_reset_token: "asdf1234" ) }
    let(:mail) { UserMailer.password_reset(user) }

    it 'has the right subject' do
      expect(mail.subject).to eq("Password Reset")
    end

    it 'has the right sender' do
      expect(mail.from).to eq(['notifications@scirate.com'])
    end

    it 'has the right body content' do
      expect(mail.body.encoded).to match("To reset your password, click the URL below.")
    end

    it 'renders the receiver email' do
       expect(mail.to).to eq([user.email])
    end

    it 'assigns @name' do
      expect(mail.body.encoded).to match(user.fullname)
    end

    it 'assigns the right url' do
      expect(mail.body.encoded).to match( reset_password_confirm_url(user.password_reset_token))
    end
  end

  describe "email change notification email" do
    let(:old_email) { 'old@old.com' }
    let(:user) { FactoryGirl.create(:user) }
    let(:mail) { UserMailer.email_change(user, old_email) }

    it 'has the right subject' do
      expect(mail.subject).to eq("Your email address has been changed")
    end

    it 'has the right sender' do
      expect(mail.from).to eq(['notifications@scirate.com'])
    end

    it 'has the right body content' do
      expect(mail.body.encoded).to match("email address associated with your SciRate account has recently been changed.")
      expect(mail.body.encoded).to match(old_email)
      expect(mail.body.encoded).to match(user.email)
    end

    it 'should get sent to the old address' do
       expect(mail.to).to eq([old_email])
    end

    it 'assigns @name' do
      expect(mail.body.encoded).to match(user.fullname)
    end

    it 'contains the right place to complain to' do
      expect(mail.body.encoded).to match("support@#{Settings::HOST}")
    end
  end
end
