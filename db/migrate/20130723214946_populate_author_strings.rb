class PopulateAuthorStrings < ActiveRecord::Migration
  def up

    puts "Denormalizing authors (this may take a while)"
    i = 0
    loop do
      ids = Paper.where(author_str: nil).limit(1000).pluck(:id)
      break if ids.empty?
      Paper.where(id: ids).update_all("author_str = (select string_agg(authors.fullname, ', ') from authors inner join authorships on authors.id = authorships.author_id where authorships.paper_id = papers.id)")
      i += 1
      p i * 1000
    end
  end

  def down
    raise
  end
end
