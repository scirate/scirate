def map_models(key, query)
  map = {}
  query.each do |model|
    map[model.send(key)] = model
  end
  map
end

def map_exists(key, query)
  map = {}
  query.pluck(key).each do |val|
    map[val] = true
  end
  map
end

def later(&b)
  future do
    ActiveRecord::Base.connection_pool.with_connection(&b)
  end
end

def end_of_today
  Time.now.utc.at_end_of_day
end

def execute(sql, *args)
  sanitized = ActiveRecord::Base.send(:sanitize_sql_array, [sql]+args)
  ActiveRecord::Base.connection.execute(sanitized).to_a
end
