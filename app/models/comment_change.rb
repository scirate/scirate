class CommentChange < ActiveRecord::Base
  # Event types
  CREATED = 'created'
  EDITED = 'edited'
  DELETED = 'deleted'
  RESTORED = 'restored'

  belongs_to :comment
  belongs_to :user
end
