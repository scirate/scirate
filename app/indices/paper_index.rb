ThinkingSphinx::Index.define :paper, with: :active_record, delta: true do
  indexes identifier, sortable: true
  indexes title
  indexes abstract
  indexes authors.fullname, as: :authors_fullname
  indexes authors.searchterm, as: :authors_searchterm

  has :scites_count, :comments_count, :pubdate
  has cross_lists.feed_id, as: :feed_ids
end
