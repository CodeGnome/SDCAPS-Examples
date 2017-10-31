# Ruby module to query the table name via SQL.
module ExampleQuery
  def self.table_name
    path = "/srv/db/#{ENV['DB']}"
    db   = SQLite3::Database.new path
    sql =<<-'SQL'
      SELECT name FROM sqlite_master
       WHERE type='table'
       LIMIT 1;
    SQL
    db.get_first_value sql
  end
end
