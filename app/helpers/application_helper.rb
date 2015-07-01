module ApplicationHelper
  def status_warning
    raw "<span class=\"warning\">#{current_user.account_status}:</span>"
  end

  def timeago(dt)
    dt = Time.parse(dt) if dt.is_a? String
    raw "<abbr class=\"timeago\" title=\"#{dt.iso8601}\">#{dt.strftime("%b %d %Y %R UTC")}</abbr>"
  end

  def user_link(user)
    raw "<a href='/#{h(user.username)}'>#{h(user.fullname)}</a>"
  end
end
