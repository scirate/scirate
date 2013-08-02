require 'spec_helper'

describe "Static pages" do

  subject { page }

  shared_examples_for "all static pages" do
    it { should have_heading heading }
    it { should have_title page_title }
  end

  describe "About page" do
    before { visit about_path }
    let(:heading)    { 'About' }
    let(:page_title) { 'About' }

    it_should_behave_like "all static pages"
  end

  it "should have the right links on the landing" do
    visit root_path

    click_link "sign in"
    page.should have_title 'Sign in'
  end
end
