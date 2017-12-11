require 'sequel'

configure do
  DB = Sequel.connect(
      adapter: 'postgres',
      host: 'db',
      database: ENV['POSTGRES_DB'],
      user: ENV['POSTGRES_USER'],
      password: ENV['POSTGRES_PASSWORD']
  )
  DB.extension :pg_array, :pg_json
end

configure :test do
  test_db_name = 'action_service_test'
  Sequel.extension :migration
  DB.execute "DROP DATABASE IF EXISTS #{test_db_name}"
  DB.execute "CREATE DATABASE #{test_db_name}"
  DB.extension :pg_array, :pg_json
  DB = Sequel.connect(
      adapter: 'postgres',
      host: 'db',
      database: test_db_name,
      user: ENV['POSTGRES_USER'],
      password: ENV['POSTGRES_PASSWORD']
  )
  Sequel::Migrator.run(DB, File.join(File.dirname(__FILE__), '../migrations'), allow_missing_migration_files: true)
end