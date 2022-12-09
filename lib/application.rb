# frozen_string_literal: true

# This is a single file Rails application used as a skeleton for practice excercises

# Load all Rails components
require 'rails/all'

require_relative './helpers'

# config/database.yml
ENV['DATABASE_URL'] = "sqlite3::memory:"
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

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
  config.active_record.legacy_connection_handling = false
  config.hosts = []

  config.logger = ActiveSupport::Logger.new(ENV['LOG'] == '1' ? $stdout : IO::NULL)

  routes.append do
    root to: 'welcome#index'

    ChapterHelpers.extend!(:routes, self)
  end
end

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end

class ApplicationController < ActionController::Base
end

class WelcomeController < ApplicationController
  def index
    render inline: 'Hi!'
  end
end
