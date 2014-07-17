class IndexFeedsOnUidAndLastPaperDate < ActiveRecord::Migration
  def change
    add_index :feeds, [:uid, :last_paper_date], order: { uid: :desc, last_paper_date: :desc }
  end
end
