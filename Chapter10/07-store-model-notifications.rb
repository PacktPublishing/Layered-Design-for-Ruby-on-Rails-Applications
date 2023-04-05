require_relative "./prelude"
using ChapterHelpers

class User::Notifications
  include StoreModel::Model
  attribute :enabled, :boolean, default: true
  attribute :email_enabled, :boolean, default: true
  attribute :sms_enabled, :boolean, default: true

  attribute :email, :string
  attribute :phone_number, :string

  def email_enabled? = enabled? && super

  def sms_enabled? = enabled? && super
end

class User < ApplicationRecord
  self.table_name = "store_users"

  attribute :notifications, Notifications.to_type
end

user = User.new(notifications: {enabled: "t", email_enabled: "t", sms_enabled: "f"})
user.notifications.enabled?

user.notifications.email_enabled?

user.notifications.sms_enabled?

user.save!
user.reload

user.notifications.sms_enabled = true
user.save!
user.reload

user.notifications.enabled?

user.notifications.email_enabled?

user.notifications.sms_enabled?
