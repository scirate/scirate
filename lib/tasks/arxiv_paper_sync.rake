namespace :arxiv do
  desc "Idempotent master arxiv paper update task"
  task paper_sync: :environment do
    last_update = System.pluck(:arxiv_sync_dt).first # only one entry in table named 'system'
    update_threshold = Time.now.utc.change(min: 0)

    if last_update < update_threshold
      puts "Last OAI sync was at #{last_update}, running update..."
      Rake::Task['arxiv:oai_update'].invoke
    else
      puts "Already updated this hour, not running update."
    end
  end
end
