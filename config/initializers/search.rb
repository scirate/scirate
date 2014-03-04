index = if Settings::STAGING
  "scirate_staging"
elsif Rails.env == 'production'
  "scirate_live"
else
  "scirate_#{Rails.env}"
end

Search.configure(index: index)
