FactoryGirl.define do
  factory :user do
    sequence(:name)  { |n| "Person #{n}" }
    sequence(:email) { |n| "person_#{n}@example.com"}   
    password "foobar"
    sequence(:active){ |n| true }
  end

  factory :paper do
    sequence(:title)       { |n| "On Hilbert's #{n}th Problem" }
    sequence(:authors)     { |n| ["Some Author #{n}a", "Some Author #{n}b"] }
    sequence(:abstract)    { |n| "We solve Hilbert's #{n}th problem." }
    sequence(:identifier)  { |n| "#{1000+n}.#{1000+n}" }
    sequence(:url)         { |n| "http://arxiv.org/abs/#{1000+n}.#{1000+n}" }
    sequence(:pubdate)     { |n| Date.today }
    sequence(:updated_date){ |n| Date.today }
  end

  factory :comment do
    sequence(:content)     { |n| "This is test comment #{n}!" }
    user
    paper
  end
end
