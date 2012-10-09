class AddPdfUrlToPaper < ActiveRecord::Migration
  def change
    add_column :papers, :pdf_url, :string
  end
end
