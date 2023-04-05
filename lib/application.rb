# frozen_string_literal: true

# This is a single file Rails application used as a skeleton for practice excercises

# Load all Rails components
require "rails/all"

require_relative "./helpers"

# config/database.yml
database = File.expand_path(File.join(__dir__, "..", "rails-book.sqlite3"))
ENV["DATABASE_URL"] = "sqlite3:#{database}"
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: database)
ActiveRecord::Base.logger = ActiveSupport::Logger.new((ENV["LOG"] == "1") ? $stdout : IO::NULL)

# db/schema.rb
ActiveRecord::Schema.define do
  self.verbose = false

  ChapterHelpers.extend!(:schema, self)
end

require "active_job/queue_adapters/inline_adapter"

# Custom Active Job adapter to perform jobs synchronously,
# but within a new thread (so, it's a combination of async and inline).
# That better ressembles the production queueing adapters by executing jobs
# within non-main threads.
module ActiveJob
  module QueueAdapters
    class AsyncInlineAdapter < InlineAdapter
      def enqueue(job)
        Thread.new { Base.execute(job.serialize) }.join
      end
    end
  end
end

# Custom Action Cable adapter which prints broadcast to standard output
module ActionCable
  module SubscriptionAdapter
    class TestPrint < Test
      def broadcast(channel, payload)
        puts "[CABLE BROADCAST] channel=#{channel} data=#{payload.inspect}"
        super
      end
    end
  end
end

# Prevent Rails from trying to require the subscription adapter file
$LOADED_FEATURES << "action_cable/subscription_adapter/test_print"

# config/application.rb
class App < Rails::Application
  config.root = __dir__
  config.eager_load = false
  config.consider_all_requests_local = true
  config.action_dispatch.show_exceptions = false
  config.secret_key_base = "i_am_a_secret"
  config.active_storage.service_configurations = {"local" => {"service" => "Disk", "root" => "./storage"}}
  config.active_storage.service = :local
  config.active_job.queue_adapter = :async_inline
  config.action_mailer.show_previews = false

  config.hosts = []

  config.logger = ActiveSupport::Logger.new((ENV["LOG"] == "1") ? $stdout : IO::NULL)

  # Add current chapter views
  prelude_path = caller_locations(1, 10).find { _1.path.include?("prelude.rb") }&.path
  config.paths["app/views"] << File.join(File.dirname(prelude_path), "views") if prelude_path

  routes.append do
    root to: "welcome#index"

    post "/_/chapters/:id" => "welcome#load_example", :as => :example
    delete "/_/chapters" => "welcome#reset_examples", :as => :examples_reset

    ChapterHelpers.extend!(:routes, self)
  end

  config.after_initialize do
    require_relative "./app"
  end
end

# Configure Action Cable
ActionCable.server.config.cable = {
  "adapter" => "test_print"
}

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
