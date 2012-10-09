namespace :db do
  desc "Add PDF url to papers -- assumes all papers are from arXiv"
  task add_pdf_url: :environment do

    Paper.reset_column_information
    Paper.all.each do |p|
      if p.pdf_url.nil? then
        p.pdf_url = "http://arxiv.org/pdf/#{p.identifier}.pdf"
        p.save(validate: false)
      end
    end
  end
end
