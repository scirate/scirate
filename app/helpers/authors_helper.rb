module AuthorsHelper
  def author_link_to(author, paper)
    if paper.nil?
      link_to(author.fullname.html_safe, "/search?q=au:#{author.searchterm}")
    else
      link_to(author.fullname.html_safe, "/search?q=au:#{author.searchterm}+in:#{paper.categories[0].feed_uid}")
    end
  end
end
