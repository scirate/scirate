class AddCreationChangeForEveryComment < ActiveRecord::Migration
  def up
    puts "Recording creation event for every existing comment..."
    Comment.all.each do |comment|
      comment.record_change!(CommentChange::CREATED, comment.user_id)
    end
  end

  def down
    raise NotImplementedError
  end
end
