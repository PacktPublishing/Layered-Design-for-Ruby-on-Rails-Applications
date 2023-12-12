# frozen_string_literal: true

require_relative "../lib/helpers"
using ChapterHelpers

gems do
  # For base form object
  gem "after_commit_everywhere", "~> 1.3.0"
  # For shorter Arel syntax in filters
  gem "arel-helpers", "~> 2.14.0"
  # For filter objects
  gem "rubanok", "~> 0.4.0"
  # For filtering specs
  gem "rspec-rails", "6.1.0"
end

schema do
  create_table :users, force: true do |t|
    t.string :name, null: true
    t.string :email, null: true, index: {unique: true}
    t.datetime :confirmed_at

    t.timestamps
  end

  create_table :projects, force: true do |t|
    t.string :name, null: true
    t.belongs_to :user, null: true
    t.datetime :started_at
    t.string :status, null: false, default: "draft"

    t.timestamps
  end
end

routes do
  resources :users
  resources :invitations, only: [:new, :create]
  resources :registrations, only: [:new, :create]
  resources :feedbacks, only: [:new, :create]
  resources :projects, only: [:index]
end

require_relative "../lib/boot"

class User < ApplicationRecord
  has_many :projects
end

class Project < ApplicationRecord
  include ArelHelpers::ArelTable

  belongs_to :user

  def as_json(*)
    {
      id:,
      name:,
      status:,
      started_at:
    }
  end
end

class UserMailer < ApplicationMailer
  def invite(user)
    mail(
      to: user.email,
      subject: "You've been invited!",
      body: "Hello, friend! You've been invited to learn some Ruby on Rails"
    )
  end

  def invite_copy(sender, user)
    mail(
      to: sender.email,
      subject: "Invitation copy",
      body: "You've just invited #{user.email}. Here is the invitation:\nHello, friend! You've been invited to learn some Ruby on Rails"
    )
  end

  def welcome(user)
    mail(
      to: user.email,
      subject: "Welcome!",
      body: "Welcome, #{user.name}!"
    )
  end
end

class SystemMailer < ApplicationMailer
  def feedback(from_email, from_name, message)
    mail(
      to: "support@rails-cake.test",
      reply_to: from_email,
      subject: "New feedback from #{from_name}",
      body: message
    )
  end
end
