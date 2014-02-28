ThinkingSphinx::Index.define :comment, with: :active_record, delta: true do
  indexes content
  indexes user.fullname, as: :user_fullname
  indexes user.username, as: :user_username
  has :user_id, :paper_uid
end
