#!/usr/bin/env ruby

web = 'web.scirate.com'

def run(hosts, commands)
  pids = []

  hosts.each do |host|
    cmd = "ssh scirate@#{host} 'bash -l -e -s' <<'ENDSSH'\n#{commands}\nENDSSH"
    pids << Process.spawn(cmd)
  end

  pids.each do |pid|
    Process.wait pid
  end
end

run [web], <<END
source ~/.ruby-stuff
cd ~/scirate
git fetch -f
git reset --hard origin/main
echo h3 $(git log --oneline -1 | cut -d' ' -f1) > app/views/static_pages/version.html.slim
ln -sf ~/database.yml config/database.yml
ln -sf ~/local_settings.rb local_settings.rb
bundle config set --local without 'development test'
bundle install
END

run [web], <<END
source ~/.ruby-stuff
cd ~/scirate
rake db:migrate
END

run [web], <<END
source ~/.ruby-stuff
cd ~/scirate
rake assets:precompile
sudo service scirate restart
sudo service memcached restart
./bin/delayed_job restart
END
