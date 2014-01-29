class SciteCommentUidsData < ActiveRecord::Migration
  def up
    Scite.all.each do |scite|
      begin
        scite.paper_uid = Paper.find(scite.paper_id).uid
        scite.save
      rescue Exception => e
        p e
      end
    end

    Comment.all.each do |comment|
      begin
        comment.paper_uid = Paper.find(comment.paper_id).uid
        comment.save
      rescue Exception => e
        p e
      end
    end
  end

  def down
    raise
  end
end
