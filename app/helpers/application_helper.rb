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
      "#{base_title} | #{page_title}"
    end
  end
end
