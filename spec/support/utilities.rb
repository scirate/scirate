require 'capybara/rspec'

RSpec::Matchers.define :have_title do |title|
  match do |page|
    page.body.should have_selector('title', text: full_title(title))
  end
end

RSpec::Matchers.define :have_heading do |heading|
  match do |page|
    Capybara.string(page.body).has_selector?('h1', text: heading)
  end
end

RSpec::Matchers.define :have_success_message do |message|
  match do |page|
    expect(page).to have_selector('.alert-success', text: message)
  end
end

RSpec::Matchers.define :have_error_message do |message|
  match do |page|
    expect(page).to have_selector('.alert-danger', text: message)
  end
end

#custom matcher to determine if a list of papers includes the given one
RSpec::Matchers.define :have_paper do |paper|
  match do |page|
    page.should have_content paper.uid
    page.should have_link paper.title
  end
end

RSpec::Matchers.define :have_comment do |content|
  match do |page|
    have_selector('.comment', text: content)
  end
end

def valid_signup(params = {})
  params[:fullname]  ||= "Example User"
  params[:email] ||= "user@example.com"
  params[:password] ||= "foobar"

  fill_in "Name",                  with: params[:fullname]
  fill_in "Email",                 with: params[:email]
  fill_in "user_password",              with: params[:password]
  click_button "Sign up"
end

def signup
  click_button "Sign up"
end

def update
  click_button "Update"
end

def sign_out
  click_link "Sign out"
end

def become(user)
  # In controller specs we can manipulate the context directly
  request.session[:remember_token] = user.remember_token
end


def sign_in(user)
  # For capybara
  visit login_path
  fill_in "Email",    with: user.email
  fill_in "Password", with: user.password
  click_button "Sign in"

  # For functional tests (TODO: distinguish between these two cases)
  post "/login", email_or_username: user.email, password: user.password
end

def sign_in_with_google
  OmniAuth.config.mock_auth[:google_oauth2] = MockAuth.google

  visit login_path
  click_link "Sign in with Google"
end

def sign_up_with_google
  sign_in_with_google

  #click_button "Confirm And Create This Account"
end

def google_user
  User.where(email: MockAuth.google.info.email).first
end

def last_email
  ActionMailer::Base.deliveries.last
end

def reset_email
  ActionMailer::Base.deliveries = []
end

class MockAuth
  def self.google
    OmniAuth::AuthHash.new({
      provider: 'google',
      uid: 'some_uid',
      info: {
        name: "Jaiden Mispy",
        email: "jaiden@contextualsystems.com"
      },
      credentials: {
        token: "some_token",
        expires_at: (Date.today+1.day).to_time.to_i
      }
    })
  end
end
