ThinkingSphinx::Index.define :paper, with: :active_record, delta: true do
  indexes uid, sortable: true
  indexes title, sortable: true
  indexes abstract
  indexes authors.fullname, as: :authors_fullname
  indexes authors.searchterm, as: :authors_searchterm
  indexes categories.feed_uid, as: :feed_uids

  has :scites_count, :comments_count, :submit_date, :update_date, :pubdate
end
