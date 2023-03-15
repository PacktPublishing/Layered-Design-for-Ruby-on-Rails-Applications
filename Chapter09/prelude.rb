require_relative "../lib/helpers"
using ChapterHelpers

gems do
  gem "action_policy", "0.6.5"
end

schema do
  create_table :users, force: true do |t|
    t.string :name, null: true
    t.string :role, null: false, default: "regular"
    t.string :dept, null: true
    t.timestamps
  end

  create_table :posts, force: true do |t|
    t.string :title, null: false
    t.belongs_to :user, null: false
    t.datetime :published_at
    t.timestamps
  end

  create_table :books, force: true do |t|
    t.string :title, null: false
    t.string :author, null: false
    t.string :isbn, null: true
    t.string :dept, null: true
    t.timestamps
  end
end

routes do
  resources :posts, only: [:index, :show, :destroy, :edit] do
    patch :publish, on: :member
  end
  resources :books, only: [:index, :new, :show, :edit, :update, :destroy]
  namespace :books do
    post "/search" => "book/search#create", :as => :searches
  end
end

require_relative "../lib/boot"

require "action_policy/rails/scope_matchers/active_record"

class ApplicationController
  rescue_from ActionPolicy::Unauthorized do |err|
    redirect_back(fallback_location: books_path, alert: err.result.message)
  end

  rescue_from ActiveRecord::RecordNotFound do |err|
    redirect_back(fallback_location: books_path, alert: "Not found")
  end

  private

  def authenticate!
    render head: :unauthenticated unless current_user
  end
end

class User < ApplicationRecord
end

class Post < ApplicationRecord
  belongs_to :user
end

class Book < ApplicationRecord
end

class ApplicationForm
  include ActiveModel::API
  include ActiveModel::Attributes

  def save
    return false unless valid?

    submit!
  end

  def model_name
    ActiveModel::Name.new(nil, nil, self.class.name.sub(/Form$/, ""))
  end

  private

  def submit!
    raise NotImplementedError
  end
end

class ApplicationPolicy < ActionPolicy::Base
  authorize :user, allow_nil: true
  delegate :permission?, to: :user

  # The features below will be added in Action Policy v1.0
  alias_rule :index?, :show?, to: :view?

  class << self
    def inherited(subclass)
      # define a resource-named reader as a #resource alias
      resource_reader = subclass.name.demodulize.sub(/Policy$/, "").underscore
      alias_method :"#{resource_reader}", :record
    end
  end
end
