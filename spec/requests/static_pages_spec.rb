require 'spec_helper'

describe "Static pages" do
  describe "About page" do
    before { visit about_path }

    it "has the right content" do
      expect(page).to have_heading "About"
      expect(page).to have_title "About"
    end
  end
end
