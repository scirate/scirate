require 'spec_helper'

describe "Static pages" do
  describe "About page" do
    before { visit about_path }

    it "has the right content" do
      page.should have_heading "About"
      page.should have_title "About"
    end
  end
end
