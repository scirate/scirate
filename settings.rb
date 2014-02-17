module Settings
  # Definable application-wide settings which can be
  # overrided by either a local_settings.rb file or values
  # of ENV (in that order). Intended to separate SciRate
  # settings (some of which are sensitive) from general Rails 
  # configuration.
  
  # An ordered list of the top-level arxiv categories which may be parents 
  # to other categories. Used for the sidebar, search etc
  ARXIV_FOLDERS = ['astro-ph', 'cond-mat', 'gr-qc', 'hep-ex', 'hep-lat', 'hep-ph', 'hep-th', 'math-ph', 'nlin', 'nucl-ex', 'nucl-th', 'physics', 'quant-ph', 'math', 'cs', 'q-bio', 'q-fin', 'stat']

  # Hostname to put in emails and such
  HOST = "scirate.com"

  # Whether to use Mathjax rendering for tex
  ENABLE_MATHJAX = true

  # Since usernames are in root url namespace, need to reserve anything we might want later
  # These are mostly taken from https://gist.github.com/caseyohara/1453705
  RESERVED_USERNAMES = ["legal", "arxiv", "supportdetails", "support-details", "stacks", "imulus", "github", "twitter", "facebook", "google", "apple", "about", "account", "activate", "add", "admin", "administrator", "api", "app", "apps", "archive", "archives", "auth", "blog", "cache", "cancel", "careers", "cart", "changelog", "checkout", "codereview", "compare", "config", "configuration", "connect", "contact", "create", "delete", "direct_messages", "documentation", "download", "downloads", "edit", "email", "employment", "enterprise", "faq", "favorites", "feed", "feedback", "feeds", "fleet", "fleets", "follow", "followers", "following", "friend", "friends", "gist", "group", "groups", "help", "home", "hosting", "hostmaster", "idea", "ideas", "index", "info", "invitations", "invite", "is", "it", "job", "jobs", "json", "language", "languages", "lists", "login", "logout", "logs", "mail", "map", "maps", "mine", "mis", "news", "oauth", "oauth_clients", "offers", "openid", "order", "orders", "organizations", "plans", "popular", "post", "postmaster", "privacy", "projects", "put", "recruitment", "register", "remove", "replies", "root", "rss", "sales", "save", "search", "security", "sessions", "settings", "shop", "signup", "sitemap", "ssl", "ssladmin", "ssladministrator", "sslwebmaster", "status", "stories", "styleguide", "subscribe", "subscriptions", "support", "sysadmin", "sysadministrator", "terms", "tour", "translations", "trends", "unfollow", "unsubscribe", "update", "url", "user", "weather", "webmaster", "widget", "widgets", "wiki", "ww", "www", "wwww", "xfn", "xml", "xmpp", "yaml", "yml", "chinese", "mandarin", "spanish", "english", "bengali", "hindi", "portuguese", "russian", "japanese", "german", "wu", "javanese", "korean", "french", "vietnamese", "telugu", "chinese", "marathi", "tamil", "turkish", "urdu", "min-nan", "jinyu", "gujarati", "polish", "arabic", "ukrainian", "italian", "xiang", "malayalam", "hakka", "kannada", "oriya", "panjabi", "sunda", "panjabi", "romanian", "bhojpuri", "azerbaijani", "farsi", "maithili", "hausa", "arabic", "burmese", "serbo-croatian", "gan", "awadhi", "thai", "dutch", "yoruba", "sindhi", "ac", "ad", "ae", "af", "ag", "ai", "al", "am", "an", "ao", "aq", "ar", "as", "at", "au", "aw", "ax", "az", "ba", "bb", "bd", "be", "bf", "bg", "bh", "bi", "bj", "bm", "bn", "bo", "br", "bs", "bt", "bv", "bw", "by", "bz", "ca", "cc", "cd", "cf", "cg", "ch", "ci", "ck", "cl", "cm", "cn", "co", "cr", "cs", "cu", "cv", "cx", "cy", "cz", "dd", "de", "dj", "dk", "dm", "do", "dz", "ec", "ee", "eg", "eh", "er", "es", "et", "eu", "fi", "fj", "fk", "fm", "fo", "fr", "ga", "gb", "gd", "ge", "gf", "gg", "gh", "gi", "gl", "gm", "gn", "gp", "gq", "gr", "gs", "gt", "gu", "gw", "gy", "hk", "hm", "hn", "hr", "ht", "hu", "id", "ie", "il", "im", "in", "io", "iq", "ir", "is", "it", "je", "jm", "jo", "jp", "ke", "kg", "kh", "ki", "km", "kn", "kp", "kr", "kw", "ky", "kz", "la", "lb", "lc", "li", "lk", "lr", "ls", "lt", "lu", "lv", "ly", "ma", "mc", "md", "me", "mg", "mh", "mk", "ml", "mm", "mn", "mo", "mp", "mq", "mr", "ms", "mt", "mu", "mv", "mw", "mx", "my", "mz", "na", "nc", "ne", "nf", "ng", "ni", "nl", "no", "np", "nr", "nu", "nz", "om", "pa", "pe", "pf", "pg", "ph", "pk", "pl", "pm", "pn", "pr", "ps", "pt", "pw", "py", "qa", "re", "ro", "rs", "ru", "rw", "sa", "sb", "sc", "sd", "se", "sg", "sh", "si", "sj", "sk", "sl", "sm", "sn", "so", "sr", "ss", "st", "su", "sv", "sy", "sz", "tc", "td", "tf", "tg", "th", "tj", "tk", "tl", "tm", "tn", "to", "tp", "tr", "tt", "tv", "tw", "tz", "ua", "ug", "uk", "us", "uy", "uz", "va", "vc", "ve", "vg", "vi", "vn", "vu", "wf", "ws", "ye", "yt", "yu", "za", "zm", "zw"]

  #####
  # Sensitive development settings
  # Define in local_settings.rb
  #####

  # Gmail auth details used in development to test UserMailer mail
  GMAIL_SMTP_USER = ''
  GMAIL_SMTP_PASSWORD = ''

  #####
  # Sensitive production settings
  # Define in Heroku ENV config
  #####

  # Rails secret token for signing cookies
  if ENV['RAILS_ENV'] == 'production'
    SECRET_KEY_BASE = '' 
    SECRET_TOKEN = ''
  else
    SECRET_KEY_BASE = '027d35bd099187fe704c6cb189fced29f1562ff46397d77c8e6cfc3e2e66667b98ecb61fa0809807b80934fde0ac4b874ac6c6a3a78e3dcd8e0d906288d1306f'
    SECRET_TOKEN = '4b4d948fe0bdde9d1f66af4bcbe15cec68339f7445038032f5313e2f00c36eacb2c8b780fe40e5e9106c9ecbc175893a579f9d138942195eb3fe76e51a767ebe'
  end

  # Sendgrid auth details used in production to send UserMailer mail
  SENDGRID_USERNAME = ''
  SENDGRID_PASSWORD = ''
  
  # New Relic app monitoring auth details
  # NEW_RELIC_LICENSE_KEY = ''
  # NEW_RELIC_APP_NAME = ''

  def self.override(key, val)
    Settings.send(:remove_const, key) if Settings.const_defined?(key, false)
    Settings.const_set(key, val)
  end
end

begin
  require File.expand_path('../local_settings', __FILE__)

  # To override settings for development purposes, make
  # a local_settings.rb file which looks like this:
  #
  # module LocalSettings
  #   SOME_SETTING = 'foo'
  # end

  LocalSettings.constants.each do |key|
    Settings.override(key, LocalSettings.const_get(key))
  end
rescue LoadError # Don't worry if there's no local_settings.rb file
end

ENV.each do |key, val|
  begin
    Settings.override(key, val)
  rescue NameError # Ruby constants have a stricter syntax than ENV
  end
end
