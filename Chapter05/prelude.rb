# frozen_string_literal: true

require_relative "../lib/helpers"
using ChapterHelpers

gems do
  # For service objects
  gem "dry-initializer", "3.1.1"
  # For specifications
  gem "rspec-rails", "4.0.0"
end

schema do
  create_table :users, force: true do |t|
    t.string :name, null: false
    t.string :gh_id, null: false
    t.timestamps null: true
  end

  create_table :issues, force: true do |t|
    t.belongs_to :user
    t.string :title, null: false
    t.text :body
    t.timestamps null: true
  end

  create_table :pull_requests, force: true do |t|
    t.belongs_to :user
    t.string :title, null: false
    t.text :body
    t.string :branch
    t.timestamps null: true
  end
end

routes do
  post "/callbacks/github", to: "githooks#create"
end

require_relative "../lib/boot"

class User < ApplicationRecord
  has_many :issues
  has_many :pull_requests
end

class Issue < ApplicationRecord
  belongs_to :user
end

class PullRequest < ApplicationRecord
  belongs_to :user
end

ISSUE_PAYLOAD = {
  type: "issue", action: "opened",
  issue: {user: {login: "palkan"}, title: "Slimming down controllers", body: "Let's do that"}
}.to_json.freeze

PR_PAYLOAD = {
  type: "pull_request", action: "opened",
  pull_request: {user: {login: "palkan"}, base: {label: "feat/slim"}, title: "Slim down controllers", body: "Let's do that"}
}.to_json.freeze
