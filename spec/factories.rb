FactoryGirl.define do
  factory :feed do
    sequence(:uid)        { |n| "feed.#{n}" }
    sequence(:fullname)       { |n| "Feed #{n}" }
    sequence(:source)     { |n| "arxiv" }
    last_paper_date       Date.today
  end

  factory :user do
    sequence(:fullname) { |n| "Person #{n}" }
    sequence(:username) { |n| "person_#{n}" }
    sequence(:email)    { |n| "person_#{n}@example.com"}
    sequence(:active)   { |n| true }
    account_status User::STATUS_USER
    password "foobar"
    password_confirmation "foobar"
  end

  factory :category do
    feed
    sequence(:position) { |n| n}
  end

  factory :paper do |p|
    sequence(:title)       { |n| "On Hilbert's #{n}th Problem" }
    sequence(:abstract)    { |n| "We solve Hilbert's #{n}th problem." }
    sequence(:submitter)   { |n| "Hilbert N. Grande" }
    sequence(:uid)  { |n| "#{1000+n}/#{1000+n}.#{1000+n}" }
    sequence(:submit_date) { |n| Date.today }
    sequence(:update_date) { |n| Date.today }
    sequence(:abs_url)     { |n| "http://arxiv.org/abs/#{1000+n}/#{1000+n}.#{1000+n}" }
    sequence(:pdf_url)     { |n| "http://arxiv.org/pdf/#{1000+n}/#{1000+n}.#{1000+n}" }
    sequence(:author_str)  { |n| "Hilbert N. Grande, Lucrezia Mongfish" }

    factory :paper_with_authors do
      ignore do
        authors_count 2
      end

      after(:create) do |paper, evaluator|
        FactoryGirl.create_list(:author, evaluator.authors_count, paper: paper)
      end
    end

    after(:create) do |paper, evaluator|
      create(:category, paper: paper, feed: Feed.first)
    end
  end

  factory :author do
    paper
    sequence(:position)   { |n| n }
    sequence(:fullname)   { |n| "Lucrezia Mongfish" }
    sequence(:searchterm) { |n| "Mongfish_L" }
  end

  factory :comment do
    user
    paper
    sequence(:content)  { |n| "This is test comment #{n}!" }
  end
end
