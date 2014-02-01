module AuthorsHelper
  def author_link_to(author)
    link = link_to(author.fullname.html_safe, "/search?q=au:#{author.searchterm}")

    if @search
      terms = [@search.authors.map { |a| a.split("_")[0] }, @search.general_term].flatten
      highlight(link, terms.reject(&:nil?))
    else
      link
    end
  end
end
