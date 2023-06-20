# frozen_string_literal: true

require_relative "../lib/helpers"
using ChapterHelpers

gems do
  # For Active Job and pure Sidekiq comparison
  gem "sidekiq", "6.0.1"
  # For custom Active Storage analyzer
  gem "id3tag", "0.14.0"
  # For custom wrapper/adaper example
  gem "bitly", "3.0.0"
  # To stub Bitly HTTP requests
  gem "webmock", "3.18.0"
end

schema do
  create_table :users, force: true do |t|
    t.string :name, null: true
  end

  create_table :posts, force: true do |t|
    t.string :title, null: true
  end
end

require_relative "../lib/boot"

# Set this global var to disable Sidekiq warning message
$TESTING = true # rubocop:disable Style/GlobalVars
require "sidekiq/testing"
Sidekiq::Testing.inline!

# Use inline adapter for Active Job as well
ActiveJob::Base.queue_adapter = :inline

# To use #stub in tests
require "minitest/mock"

class User < ApplicationRecord
end

User.create!(name: "Vova")

module Analytics
  class Error < StandardError
  end

  class APIError < Error
  end

  class UserNotFound < Error
  end

  class Tracker
    def self.push_event(payload)
      event = payload.fetch(:event)
      user = payload.fetch(:user)

      puts "[ANALYTICS] #{event}: #{user[:name]} (#{user[:id]})"
    end
  end
end

# Extend GlobalID to show human-readable representation
# in #inspect
class GlobalID
  alias_method :inspect, :to_s
end

# Stub Rails credentials
module Rails
  def self.credentials
    Object.new.tap do
      _1.define_singleton_method(:bitly_api_token) { ENV.fetch("BITLY_API_TOKEN", "bitlys") }
    end
  end
end

# Intercept Bit.ly requests if no real token is provided
if ENV["BITLY_API_TOKEN"].blank?
  require "webmock"
  WebMock.enable!

  mocked_response = {
    "created_at" => "2022-12-10T23:51:47+0000",
    "link" => "https://bit.ly/3Use6uj",
    "id" => "bit.ly/3Use6uj",
    "long_url" => "https://rubyonrails.org"
  }.to_json

  WebMock::API.stub_request(:post, "https://api-ssl.bitly.com/v4/shorten")
    .to_return(status: 200, body: mocked_response, headers: {"content-type" => "application/json"})
end
