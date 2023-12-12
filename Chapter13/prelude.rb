require_relative "../lib/helpers"
using ChapterHelpers

gems do
  gem "imgproxy", "2.1.0"
  gem "yabeda", "0.11.0"
end

schema do
  create_table :users, force: true do |t|
    t.string :name, null: true
    t.timestamps
  end
end

routes do
end

configure do
  next if $logging == false

  # Setup a production-like logger
  logger = ActiveSupport::Logger.new($stdout)
  logger.formatter = Logger::Formatter.new
  logger.level = :debug
  config.logger = ActiveSupport::TaggedLogging.new(logger)

  config.log_tags = [
    :request_id,
    proc { |request| request.headers["X-USER-ID"] }
  ]
end

require "net/http"
require "json"

require_relative "../lib/boot"

class User < ApplicationRecord
end
