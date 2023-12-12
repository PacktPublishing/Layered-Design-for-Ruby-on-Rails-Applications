# frozen_string_literal: true

require_relative "../lib/helpers"
using ChapterHelpers

schema do
  create_table :accounts, force: true do |t|
    t.string :name
  end

  create_table :users, force: true do |t|
    t.string :name, null: true
    t.belongs_to :account, null: true
  end

  create_table :posts, force: true do |t|
    t.string :title, null: false
    t.boolean :draft, null: false, default: false
    t.datetime :deleted_at, null: true
    t.belongs_to :user
    t.json :tags, null: true
    t.timestamps null: true
  end

  create_table :bookmarks, force: true do |t|
    t.belongs_to :user
    t.belongs_to :post
    t.json :tags, null: true
  end
end

require_relative "../lib/boot"
# Enable logging to see queries
ActiveRecord::Base.logger = ActiveSupport::Logger.new($stdout)

class Account < ApplicationRecord
  has_many :users, dependent: :destroy
end

class User < ApplicationRecord
  belongs_to :account, optional: true

  has_many :posts, dependent: :destroy
  has_many :bookmarks, dependent: :destroy
end

class Post < ApplicationRecord
  belongs_to :user, optional: true

  has_many :bookmarks, dependent: :destroy
end

class Bookmark < ApplicationRecord
  belongs_to :user
  belongs_to :post
end
