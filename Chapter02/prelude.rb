# frozen_string_literal: true

require_relative "../lib/helpers"
using ChapterHelpers

# EXAMPLE: 00-book-active-record.rb, 01-book-data-mapper.rb
schema do
  create_table :books, force: true do |t|
    t.string :title, null: false
    t.string :category, null: true
    t.timestamps null: true
  end
end

# EXAMPLE: 02-posts-comments-rails-rom.rb, 03-post-validations.rb

# Schema definition for users, posts and comments.
schema do
  create_table :users, force: true do |t|
    t.string :name, null: true
    t.text :address, null: true
    t.string :address_country, null: true
    t.string :address_city, null: true
    t.text :address_street, null: true
    t.string :address_zip, null: true
  end

  create_table :posts, force: true do |t|
    t.string :title, null: false
    t.boolean :published, null: false, default: false
    t.boolean :draft, null: false, default: false
    t.date :publish_date, null: true
    t.string :status, null: false, default: "draft"
    t.string :author, null: true
    t.belongs_to :user
  end

  create_table :comments, force: true do |t|
    t.string :body, null: false
    t.belongs_to :user
    t.belongs_to :post
  end
end

# Add Rom-rb
gems do
  gem "rom", "~> 5.3.0", require: false
  gem "rom-sql", "~> 3.6.1", require: false
end

# EXAMPLE: 08-books-controller.rb
routes do
  resources :books, only: [:index]
  resources :categories, only: [:index, :show]
end

# EXAMPLE: 12-active-model-vs-struct-performance.rb
gems do
  gem "benchmark-ips", "2.10.0"
  gem "benchmark-memory", "0.2.0"
end

require_relative "../lib/boot"
# Enable logging to see queries
ActiveRecord::Base.logger = ActiveSupport::Logger.new($stdout)

# Fix ROM vs Rails 7.1 incompatibility: https://github.com/rom-rb/rom/issues/684
on_const_load("ROM::SQL::Schema::Inferrer") do |mod|
  mod.__define_with__
end

require "rom"
require "rom-sql"

# Mimic Hanami Model. It doesn't work with Ruby 3.2 and no longer supported.
# Based on https://github.com/hanami/model/blob/main/lib/hanami/repository.rb
module Hanami
  class Repository
    def self.config = @config ||= ROM::Configuration.new(:sql, ENV.fetch("DATABASE_URL").sub("sqlite3", "sqlite"))

    def self.container = @container ||= ROM.container(config)

    def self.inherited(base)
      base.alias_method base.relation_name, :relation

      fiber = Fiber.new do
        relation_name = base.relation_name
        a = base.instance_variable_get(:@associations)

        klass = Class.new(ROM::Relation[:sql]) do
          schema(relation_name, infer: true) do
            associations(&a) if a
          end

          auto_struct(true)
        end

        Repository.config.register_relation(klass)
      end

      trace = TracePoint.new(:end) do |event|
        next unless event.self == base

        fiber.resume
      end.enable
    end

    def self.associations(&block) = @associations = block

    def self.relation_name = name.sub(/Repository$/, "").underscore.pluralize.to_sym

    def initialize
      @relation = Repository.container.relations[self.class.relation_name]
    end

    private

    attr_reader :relation
  end
end

# EXAMPLE: 01-book-data-mapper.rb
#
# Simple repository implementation.
DB = SQLite3::Database.new(ENV["DATABASE_URL"].sub(/^sqlite3:/, ""))

class BookRepository
  def self.insert(title:, category: nil)
    rows = DB.execute <<~SQL
      insert into books (title, category)
      values ('#{title}', #{category ? "'#{category}'" : "NULL"})
      returning id
    SQL

    rows.first.first
  end

  def self.find(id)
    rows = DB.execute <<~SQL
      select title, category
      from books
      where id = #{id}
    SQL

    row = rows.first
    return unless row

    Book.new(*row)
  end
end

# EXAMPLE: 05-post-publishing-validator.rb
#
# Add translations for validations
I18n.backend.store_translations(:en,
  activerecord: {
    errors: {
      models: {
        post: {
          attributes: {
            publish_date: {
              not_tuesday: "Should not be on Tuesday"
            }
          }
        }
      }
    }
  })
