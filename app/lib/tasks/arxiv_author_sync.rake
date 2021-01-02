namespace :arxiv do
  desc "Idempotent arxiv user authorship sync task"
  task author_sync: :environment do
    daily_update = Time.now.utc.change(hour: Settings::ARXIV_UPDATE_HOUR)

    last_author_update = System.pluck(:arxiv_author_sync_dt).first
    if last_author_update < daily_update
      puts "Last author id sync was at #{last_author_update}, running update..."
      Rake::Task['arxiv:authorship_update'].invoke
    else
      puts "Author identifiers up to date, no syncing needed."
    end
  end
end
