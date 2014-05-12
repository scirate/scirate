#!/usr/bin/env ruby

web1 = 'web1.scirate.com'
web2 = 'web2.scirate.com'

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

run [web1, web2], <<END
cd ~/scirate3
git fetch origin master
git reset --hard origin/master
ln -sf ~/database.yml config/database.yml
ln -sf ~/local_settings.rb local_settings.rb
bundle install
END

run [web1], <<END
cd ~/scirate3 && rake db:migrate
END

run [web1, web2], <<END
cd ~/scirate3
rake assets:precompile
sudo service scirate restart
sudo service memcached restart
END
