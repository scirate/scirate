namespace :arxiv do
  desc "Idempotent master arxiv update task"
  task sync: :environment do
    last_update = System.pluck(:arxiv_sync_dt).first

    if last_update.utc.beginning_of_day < Time.now.utc.beginning_of_day
      puts "Last OAI sync was at #{last_update.utc}, running update..."
      Rake::Task['arxiv:oai_update'].invoke
    else
      puts "Papers up to date, no syncing needed."
    end

    last_author_update = System.pluck(:arxiv_author_sync_dt).first
    if last_update.utc.beginning_of_day < Time.now.utc.beginning_of_day
      puts "Last author id sync was at #{last_author_update.utc}, running update..."
      Rake::Task['arxiv:authorship_update'].invoke
    else
      puts "Author identifiers up to date, no syncing needed."
    end


  end
end
