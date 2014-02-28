ThinkingSphinx::Index.define :paper, with: :active_record, delta: true do
  indexes uid, sortable: true
  indexes title, sortable: true
  indexes abstract
  indexes authors.fullname, as: :authors_fullname
  indexes authors.searchterm, as: :authors_searchterm
  indexes categories.feed_uid, as: :feed_uids

  # Sphinx has no real conception of a "string attribute", so we must
  # engage in this madness in order to get efficient category set filtering
  has "array_to_string(array_agg(crc32(categories.feed_uid)), ',')", as: :feed_uids_filter, type: :integer, multi: :true
  has :scites_count, :comments_count, :submit_date, :update_date, :pubdate
end
