# frozen_string_literal: true

$edge_rails = true

require_relative "../lib/helpers"
using ChapterHelpers

gems do
  # For SoftDeletable example
  gem "discard", "1.2.1"
  # For authentication examples
  gem "bcrypt", "3.1.18"
  # For contactable examples
  gem "countries", "5.2.0"
  gem "phonelib", "0.7.5"
end

schema do
  create_table :posts, force: true do |t|
    t.string :title, null: false
    t.text :content, null: false
    t.belongs_to :user, null: true
    t.string :short_name, null: true
    t.integer :word_count, null: false, default: 0
    t.integer :comments_count, null: false, default: 0
    t.boolean :is_public, null: false, default: true
    t.datetime :deleted_at, null: true
    t.integer :deleted_by_id, null: true
    t.timestamps null: true
  end

  create_table :comments, force: true do |t|
    t.text :body, null: false
    t.belongs_to :post
    t.timestamps null: true
  end

  create_table :users, force: true do |t|
    t.string :name, null: true
    t.string :email, null: true
    t.string :password_digest, null: true
    t.boolean :admin, null: false, default: false
    t.boolean :tracking_consent, null: false, default: false
    t.json :social_accounts
    t.string :phone_number
    t.string :country_code
    t.boolean :phone_number_visible, null: false, default: true
    t.boolean :contact_info_visible, null: false, default: true
  end

  create_table :contact_informations, force: true do |t|
    t.belongs_to :contactable, polymorphic: true
    t.json :social_accounts
    t.string :phone_number
    t.string :country_code
    t.boolean :phone_number_visible, null: false, default: true
    t.boolean :contact_info_visible, null: false, default: true
  end
end

routes do
  resources :posts, only: [:show, :update, :destroy, :index] do
    delete "/", to: "posts#destroy_all", on: :collection
  end

  resource :demo, only: [:show]

  get "/_/login" => "welcome#index", :as => :login
end

require_relative "../lib/boot"

require "countries/global"

ISO3166.configure do |config|
  config.locales = [:en]
end

class Post < ApplicationRecord
end

class User < ApplicationRecord
  def track_page_view!(_path)
  end
end

class ApplicationController
  private

  def authenticate!
  end
end

class UserMailer < ApplicationMailer
  def welcome(user)
    mail(
      to: "user-#{user.id}@test.local",
      subject: "Welcome!",
      body: "Welcome, #{user.name}!"
    )
  end
end

# Add translations for contextual callbacks demo
I18n.backend.store_translations(:en, current_time: "Current time is %{time}")
I18n.backend.store_translations(:ru, current_time: "Местное время: %{time}")
