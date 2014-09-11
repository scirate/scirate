namespace :arxiv do
  desc "Idempotent master arxiv update task"
  task sync: :environment do
    last_update = System.pluck(:arxiv_sync_dt).first
    daily_update = Time.now.utc.change(hour: Settings::ARXIV_UPDATE_HOUR)

    if Time.now.utc < daily_update
      puts "Not running sync: need to wait until ARXIV_UPDATE_HOUR"
      exit
    end

    if last_update < daily_update
      puts "Last OAI sync was at #{last_update}, running update..."
      Rake::Task['arxiv:oai_update'].invoke
    else
      puts "Papers up to date, no syncing needed."
    end

    last_author_update = System.pluck(:arxiv_author_sync_dt).first
    if last_author_update < daily_update
      puts "Last author id sync was at #{last_author_update}, running update..."
      Rake::Task['arxiv:authorship_update'].invoke
    else
      puts "Author identifiers up to date, no syncing needed."
    end
  end
end
