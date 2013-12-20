ThinkingSphinx::Index.define :paper, with: :active_record do
  indexes identifier, :sortable => true
  indexes title
  indexes abstract
  indexes author_str

  has :scites_count, :comments_count
  has cross_lists.feed_id, as: :feed_ids
end
