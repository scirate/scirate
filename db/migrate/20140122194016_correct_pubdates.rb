class CorrectPubdates < ActiveRecord::Migration
  def up
    puts "Updating pubdates..."

    offset = 0
    loop do
      rows = Paper.limit(1000).offset(offset).pluck(:id, :submit_date)
      break if rows.empty?
      rows.each do |row|
        pubdate = Paper.estimate_pubdate(row[1])
        Paper.where(id: row[0]).update_all(pubdate: pubdate)
      end
      offset += 1000
      puts offset
    end
  end

  def down
  end
end
