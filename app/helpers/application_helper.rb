module ApplicationHelper
  def describe_range(date, range)
    desc = date.to_formatted_s(:rfc822)
    if range != 0
      desc = (date-range.days).to_formatted_s(:rfc822) + " to #{desc}"
    end
    desc
  end

  def landing_column(parent)
    render partial: 'feeds/landing_column', locals: { parent: parent, feeds: parent.children }
  end

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
