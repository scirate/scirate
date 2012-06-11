class AddLastPaperDateToFeed < ActiveRecord::Migration
  def change
    add_column :feeds, :last_paper_date, :date

    add_index :feeds, :last_paper_date

    Feed.reset_column_information
    Feed.find(:all).each do |f|
      f.update_attribute :last_paper_date, f.updated_date
    end
  end
end
