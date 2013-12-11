require 'test_helper'

feature "Signup" do
  it 'should do stuff' do
    visit '/signup'
    page.must_have_content('Sign up')
  end
end
