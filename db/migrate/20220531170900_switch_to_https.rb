class SwitchToHttps < ActiveRecord::Migration[6.1]
  def change
    Paper.find_each do |p|
      p.pdf_url = p.pdf_url.gsub(/^http:\/\//,'https://')
      p.save!
    end
  end
end
