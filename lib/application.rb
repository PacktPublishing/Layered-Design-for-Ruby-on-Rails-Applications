# frozen_string_literal: true

# This is a single file Rails application used as a skeleton for practice excercises

# Load all Rails components
require 'rails/all'

require_relative './helpers'

# config/database.yml
database = File.expand_path(File.join(__dir__, "..", "rails-book.sqlite3"))
ENV["DATABASE_URL"] = "sqlite3:#{database}"
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: database)
ActiveRecord::Base.logger = ActiveSupport::Logger.new(ENV['LOG'] == '1' ? $stdout : IO::NULL)

# db/schema.rb
ActiveRecord::Schema.define do
  self.verbose = false

  ChapterHelpers.extend!(:schema, self)
end

# config/application.rb
class App < Rails::Application
  config.root = __dir__
  config.eager_load = false
  config.consider_all_requests_local = true
  config.secret_key_base = 'i_am_a_secret'
  config.active_storage.service_configurations = { 'local' => { 'service' => 'Disk', 'root' => './storage' } }
  config.active_storage.service = :local
  config.active_record.legacy_connection_handling = false
  config.active_job.queue_adapter = :inline

  config.hosts = []

  config.logger = ActiveSupport::Logger.new(ENV['LOG'] == '1' ? $stdout : IO::NULL)

  # Add current chapter views
  prelude_path = caller_locations(1, 10).find { _1.path.include?("prelude.rb") }&.path
  config.paths["app/views"] << File.join(File.dirname(prelude_path), "views") if prelude_path

  routes.append do
    root to: 'welcome#index'

    ChapterHelpers.extend!(:routes, self)
  end

  config.after_initialize do
    require_relative "./app"
  end
end

# Create Active Storage tables (unless already exists)
begin
  ActiveRecord::Base.connection.execute "select 1 from active_storage_blobs"
rescue ActiveRecord::StatementInvalid
  active_storage_migrate_dir = File.join(
    Gem.loaded_specs["activestorage"].full_gem_path,
    "db", "migrate"
  )

  Dir.children(active_storage_migrate_dir).each do
    require File.join(active_storage_migrate_dir, _1)
  end

  CreateActiveStorageTables.new.migrate(:up)
end
