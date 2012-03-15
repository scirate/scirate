namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    Rake::Task['db:reset'].invoke
    make_users
    make_papers
  end
end

def make_users
  first = User.create!(name: "Bill Rosgen",
                       email:    "rosgen@gmail.com",
                       password: "18511851",
                       password_confirmation: "18511851")
  99.times do |n|
    name  = Faker::Name.name
    email = "example-#{n+1}@intractable.ca"
    password  = "password#{n+1}"
    User.create!(name:     name,
                 email:    email,
                 password: password,
                 password_confirmation: password)
  end
end

def make_papers
  15.times do |n|
    30.times do |m|
      title = Faker::Lorem.sentence(5)
      authors = [Faker::Name.name, Faker::Name.name]
      abstract = Faker::Lorem.paragraph(5)
      identifier = "#{1001+n}.#{1001+m}"
      url = "http://arxiv.org/abs/#{identifier}"
      pubdate = Date.today - 1.months + n.days

      Paper.create!(title:      title,
                    authors:    authors,
                    abstract:   abstract,
                    identifier: identifier,
                    url:        url,
                    pubdate:    pubdate)
    end
  end
end
