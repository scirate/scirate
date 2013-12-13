require 'test_helper'

describe Author do
  it 'should make proper arXiv-style searchterms' do
    model = ArxivSync::Author.new
    model.keyname = "Biagini"
    model.forenames = ["Maria", "Enrica"]

    Author.make_searchterm(model).must_equal "Biagini_M"

    model = ArxivSync::Author.new
    model.keyname = "SuperB Collaboration"

    Author.make_searchterm(model).must_equal "Collaboration_SuperB"
  end
end
