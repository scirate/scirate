module ApplicationHelper

  def logo
      image_tag("scirate.png", alt: "Scirate", class: "round")
  end

  # Returns the full title on a per-page basis.
  def full_title(page_title)
    base_title = "Scirate"
    if page_title.empty?
      base_title
    else
      sanitize("#{base_title} | #{page_title}")
    end
  end

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
end
