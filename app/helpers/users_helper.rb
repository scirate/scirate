module UsersHelper

  # Returns the Gravatar (http://gravatar.com/) for the given user.
  def gravatar_url(user, options = { size: 50 })
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    size = options[:size]
    "https://secure.gravatar.com/avatar/#{gravatar_id}.png?s=#{size}"
  end

  def gravatar_for(user, options = { size: 50 })
    image_tag(gravatar_url(user), alt: user.fullname, class: "gravatar")
  end
end
