require 'capybara/rspec'

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
    page.body.should have_selector('title', text: full_title(title))
  end
end

RSpec::Matchers.define :have_full_title do |title|
  match do |page|
    page.body.should have_selector('title', text: title)
  end
end

RSpec::Matchers.define :have_heading do |heading|
  match do |page|
    Capybara.string(page.body).has_selector?('h1', text: heading)
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

#custom matcher to determine if a list of papers includes the given one
RSpec::Matchers.define :have_paper do |paper|
  match do |page|
    page.should have_content paper.identifier
    page.should have_link paper.title
  end
end

#custom matcher to determine if paper index page lists a recent comment
#  currently checks: first 500 chars of content, links to paper and user, and date
RSpec::Matchers.define :have_comment do |comment|
  match do |page|
    page.should have_content comment.content[0..499]
    page.should have_link comment.paper.title
    page.should have_link comment.user.name
    page.should have_content comment.created_at.to_date.to_formatted_s(format = :short)
  end
end

def valid_signup(params = {})
  params[:name]  ||= "Example User"
  params[:email] ||= "user@example.com"
  params[:password] ||= "foobar"

  fill_in "Name",                  with: params[:name]
  fill_in "Email",                 with: params[:email]
  fill_in "user_password",              with: params[:password]
  fill_in "user_password_confirmation", with: params[:password]
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

def last_email
  ActionMailer::Base.deliveries.last
end

def reset_email
  ActionMailer::Base.deliveries = []
end
