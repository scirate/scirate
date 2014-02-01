class HandleSearchtermBrackets < ActiveRecord::Migration
  def up

    places = []
    values = []

    puts "Building new searchterms..."

    Author.where("fullname SIMILAR TO '%(\\[|\\()%'").pluck(:id, :fullname).each_with_index do |row, i|
      p i if i % 10000 == 0
      places << "(?,?)"
      values << row[0] << Author.make_searchterm(row[1])
    end

    puts "Updating with new searchterms..."

    command = ["""
UPDATE authors
SET
  searchterm = myvalues.searchterm
FROM (
  VALUES
    #{places.join(',')}
) AS myvalues (id, searchterm)
WHERE authors.id = myvalues.id"""] + values

    sql = ActiveRecord::Base.send(:sanitize_sql_array, command)
    execute sql
  end

  def down
  end
end
