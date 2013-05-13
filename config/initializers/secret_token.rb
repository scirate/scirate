# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
if Rails.env.production?
  if Settings::SECRET_TOKEN
    Scirate3::Application.config.secret_token = Settings::SECRET_TOKEN
  else
    raise SecurityError, "Production server requires SECRET_TOKEN environment variable"
  end
else
  Scirate3::Application.config.secret_token = '4b4d948fe0bdde9d1f66af4bcbe15cec68339f7445038032f5313e2f00c36eacb2c8b780fe40e5e9106c9ecbc175893a579f9d138942195eb3fe76e51a767ebe'
end
