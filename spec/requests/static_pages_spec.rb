require 'spec_helper'

describe "Static pages" do

  describe "Home page" do

    it "should have the correct title and heading" do
      visit root_path
      page.should have_title ''
      page.should have_heading 'Scirate'
    end
  end

  describe "About page" do

    it "should have the title and heading 'About'" do
      visit about_path
      page.should have_title 'About'
      page.should have_heading 'About'
    end
  end
end
