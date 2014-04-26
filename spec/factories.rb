FactoryGirl.define do
  factory :feed do
    sequence(:uid)      { |n| "feed.#{n}" }
    sequence(:fullname) { |n| "Feed #{n}" }
    source              'arxiv'
    last_paper_date     { Date.today }
  end

  factory :user do
    sequence(:fullname)   { |n| "Person #{n}" }
    sequence(:username)   { |n| "person_#{n}" }
    sequence(:email)      { |n| "person_#{n}@example.com"}
    active                true
    account_status        User::STATUS_USER
    password              'foobar'
    password_confirmation 'foobar'

    factory :admin do
      account_status User::STATUS_ADMIN
    end
  end

  factory :category do
    paper
    feed
    sequence(:position) { |n| n }
  end

  factory :paper do |p|
    sequence(:title)       { |n| "On Hilbert's #{n}th Problem" }
    sequence(:abstract)    { |n| "We solve Hilbert's #{n}th problem." }
    submitter              'Hilbert N. Grande'
    sequence(:uid)         { |n| "#{1000+n}/#{1000+n}.#{1000+n}" }
    submit_date            { Date.today }
    update_date            { Date.today }
    pubdate                { Paper.estimate_pubdate(Date.today) }
    sequence(:abs_url)     { |n| "http://arxiv.org/abs/#{1000+n}/#{1000+n}.#{1000+n}" }
    sequence(:pdf_url)     { |n| "http://arxiv.org/pdf/#{1000+n}/#{1000+n}.#{1000+n}" }
    author_str             'Hilbert N. Grande, Lucrezia Mongfish'

    trait :with_comments do
      after(:create) do |paper, evaluator|
        create_list(:comment, 3, paper: paper)
        create(:deleted_comment, paper: paper, content: "this is a deleted comment")
      end
    end

    trait :with_categories do
      after(:create) do |paper, evaluator|
        create(:category, paper: paper)
      end
    end

    factory :paper_with_authors do
      after(:create) do |paper, evaluator|
        create_list(:author, 3, paper: paper)
      end
    end

    factory :paper_with_comments, traits: [:with_comments]
    factory :paper_with_categories, traits: [:with_categories]
    factory :paper_with_comments_and_categories, traits: [:with_comments, :with_categories]
  end

  factory :author do
    paper
    sequence(:position) { |n| n }
    fullname   "Lucrezia Mongfish"
    searchterm "Mongfish_L"
  end

  factory :comment do
    user
    paper
    sequence(:content) { |n| "This is test comment #{n}!" }

    factory :hidden_comment do
      hidden true
    end

    factory :deleted_comment do
      deleted true
    end
  end
end
