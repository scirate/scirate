module AuthorsHelper
  def author_link_to(author)
    link_to(author.fullname.html_safe, "/search?q=au:#{author.searchterm}")
  end
end
