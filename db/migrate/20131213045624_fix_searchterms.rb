class FixSearchterms < ActiveRecord::Migration
  def up
    Author.where(searchterm: nil).each do |author|
      author.searchterm = Author.make_searchterm(author)
      author.save
    end
  end
end
