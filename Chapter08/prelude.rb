# frozen_string_literal: true

require_relative "../lib/helpers"
using ChapterHelpers

gems do
  gem "keynote", "1.1.1"
  gem "alba", "2.1.0"
end

schema do
  create_table :users, force: true do |t|
    t.string :name, null: true

    t.timestamps
  end

  create_table :posts, force: true do |t|
    t.string :title, null: false
    t.belongs_to :user, null: false
    t.datetime :published_at
    t.boolean :draft, null: false, default: true

    t.timestamps
  end

  create_table :books, force: true do |t|
    t.string :title, null: false
  end

  create_table :book_reads, force: true do |t|
    t.belongs_to :user, null: false
    t.belongs_to :book, null: false
    t.datetime :read_at
    t.float :score

    t.timestamps
  end
end

routes do
  resources :posts, only: [:index, :show]
  resources :users, only: [:show]

  namespace :admin do
    resources :users, only: [:show]
  end

  resources :books, only: [:index, :show]
end

require_relative "../lib/boot"

class User < ApplicationRecord
  has_many :posts
end

class Post < ApplicationRecord
  belongs_to :user
end

class PostsController < ApplicationController
  def index
    @posts = Post.all
  end
end

class Book < ApplicationRecord
  has_many :book_reads
end

class BookRead < ApplicationRecord
  belongs_to :user
  belongs_to :book

  def read? = !!read_at
end

class User < ApplicationRecord
  has_many :book_reads
end

Alba.inflector = :active_support
