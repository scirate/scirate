def full_title(page_title = "")
  base_title = "Scirate"
  if page_title.empty?
    base_title
  else
    "#{base_title} | #{page_title}"
  end
end
  
RSpec::Matchers.define :have_title do |title|
  match do |page|
    page.should have_selector('title', text: full_title(title))
  end
end

RSpec::Matchers.define :have_heading do |heading|
  match do |page|
    page.should have_selector('h1', text: heading)
  end
end

RSpec::Matchers.define :have_success_message do |message|
  match do |page|
    page.should have_selector('div.flash.success', text: message)
  end
end

RSpec::Matchers.define :have_error_message do |message|
  match do |page|
    page.should have_selector('div.flash.error', text: message)
  end
end

def valid_signup(params = {})
  params[:name]  ||= "Example User"
  params[:email] ||= "user@example.com"
  params[:password] ||= "foobar"
  
  fill_in "Name",         with: params[:name]
  fill_in "Email",        with: params[:email]
  fill_in "Password",     with: params[:password]
  fill_in "Confirmation", with: params[:password]
  click_button "Sign up"
end

def signup
  click_button "Sign up"
end

def update
  click_button "Update"
end

def signout
  click_link "Sign out"
end

def sign_in(user)
  visit signin_path
  fill_in "Email",    with: user.email
  fill_in "Password", with: user.password
  click_button "Sign in"
  
  # Sign in when not using Capybara as well.
  cookies[:remember_token] = user.remember_token
end
