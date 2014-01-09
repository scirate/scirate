FactoryGirl.define do
  factory :user do
    sequence(:name)  { |n| "Person #{n}" }
    sequence(:email) { |n| "person_#{n}@example.com"}
    password "foobar"
    password_confirmation "foobar"
    sequence(:active){ |n| true }
  end

  factory :paper do |p|
    sequence(:title)       { |n| "On Hilbert's #{n}th Problem" }
    #sequence(:authors)     { |n| ["Some Author #{n}a", "Some Author #{n}b"] }
    sequence(:abstract)    { |n| "We solve Hilbert's #{n}th problem." }
    sequence(:identifier)  { |n| "#{1000+n}.#{1000+n}" }
    sequence(:url)         { |n| "http://arxiv.org/abs/#{1000+n}.#{1000+n}" }
    sequence(:pubdate)     { |n| Date.today }
    sequence(:updated_date){ |n| Date.today }
    sequence(:feed_id) { |n| Feed.default.id }
  end

  factory :authorship do
    paper
    sequence(:keyname) { |n| "Mongfish" }
    sequence(:forenames) { |n| "Lucrezia" }
    sequence(:fullname) { |n| "Lucrezia Mongfish" }
    sequence(:searchterm) { |n| "Mongfish_L" }
  end

  factory :comment do
    sequence(:content)     { |n| "This is test comment #{n}!" }
    user
    paper
  end

  factory :feed do
    sequence(:name)      { |n| "feed-#{n}" }
    sequence(:url)       { |n| "http://intractable.ca/feed/#{n}" }
    sequence(:feed_type) { |n| "arxiv" }
    updated_date Date.today
    last_paper_date Date.today
  end
end
