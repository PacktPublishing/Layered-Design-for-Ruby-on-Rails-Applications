require_relative "../lib/helpers"
using ChapterHelpers

gems do
  # For service objects
  gem "dry-initializer", "3.1.1"
  # Do not require right away to activate the mailer line,
  # which requires loading ActiveDelivery after Action Mailer
  gem "active_delivery", "~> 1.0.0", require: false
  gem "noticed", "1.6.0"

  gem "store_model", "1.6.2"
  # For specs
  gem "rspec-rails", "6.1.0"
end

schema do
  create_table :users, force: true do |t|
    t.string :name, null: true
    t.string :email, null: false
    t.string :phone_number, null: true
    t.boolean :notifications_enabled, null: false, default: true
    t.boolean :email_notifications_enabled, null: false, default: true
    t.boolean :sms_notifications_enabled, null: false, default: true
    t.timestamps
  end

  create_table :posts, force: true do |t|
    t.string :title, null: false
    t.belongs_to :user, null: false
    t.string :status, null: false, default: "draft"
    t.datetime :published_at
    t.timestamps
  end

  create_table :subscriptions, force: true do |t|
    t.belongs_to :user, null: false
    t.belongs_to :author, null: false
    t.timestamps
  end

  create_table :bit_users, force: true do |t|
    t.string :name, null: true
    t.string :email, null: true
    t.integer :notification_bits, null: false, default: 0
    t.timestamps
  end

  create_table :store_users, force: true do |t|
    t.string :name, null: true
    t.string :email, null: true
    t.json :notifications, null: false, default: {}
    t.timestamps
  end
end

require_relative "../lib/boot"

require "active_delivery"

class ApplicationService
  extend Dry::Initializer

  def self.call(...) = new(...).call
end

class User < ApplicationRecord
  has_many :posts, dependent: :destroy
  has_many :subscriptions, foreign_key: :author_id, dependent: :destroy
  has_many :subscribers, through: :subscriptions, source: :user
end

class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :author, class_name: "User"
end

class Post < ApplicationRecord
  belongs_to :user

  enum status: {draft: "draft", published: "published"}
end

class PostMailer < ApplicationMailer
  def published(post)
    mail(
      to: params[:user].email,
      subject: "A new post has been published!",
      body: "Check out #{post.title}!"
    )
  end
end

class NotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_for user
  end
end

class SMSSender
  attr_reader :number

  def initialize(number) = @number = number

  def send_later(body:)
    return unless number
    puts "[SMS MESSAGE ENQUEUED] to=#{number} body=#{body}"
  end

  def send_now(body:)
    return unless number
    puts "[SMS MESSAGE SENT] to=#{number} body=#{body}"
  end
end
