def full_title(page_title = "")
  base_title = "Scirate"
  if page_title.empty?
    base_title
  else
    "#{base_title} | #{page_title}"
  end
end
  
RSpec::Matchers.define :have_title do |title|
  match do |page|
    page.should have_selector('title', text: full_title(title))
  end
end

RSpec::Matchers.define :have_heading do |heading|
  match do |page|
    page.should have_selector('h1', text: heading)
  end
end

RSpec::Matchers.define :have_success_message do |message|
  match do |page|
    page.should have_selector('div.flash.success', text: message)
  end
end

RSpec::Matchers.define :have_error_message do |message|
  match do |page|
    page.should have_selector('div.flash.error', text: message)
  end
end
