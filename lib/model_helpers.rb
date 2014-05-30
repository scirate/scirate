def map_models(key, query)
  map = {}
  query.each do |model|
    map[model.send(key)] = model
  end
  map
end

def execute(sql, *args)
  sanitized = ActiveRecord::Base.send(:sanitize_sql_array, [sql]+args)
  ActiveRecord::Base.connection.execute(sanitized).to_a
end
