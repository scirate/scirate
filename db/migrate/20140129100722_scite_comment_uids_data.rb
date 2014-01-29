class SciteCommentUidsData < ActiveRecord::Migration
  def up
    Scite.all.each do |scite|
      scite.paper_uid = Paper.find(scite.paper_id).uid
      scite.save
    end

    Comment.all.each do |comment|
      comment.paper_uid = Paper.find(comment.paper_id).uid
      comment.save
    end
  end

  def down
    raise
  end
end
