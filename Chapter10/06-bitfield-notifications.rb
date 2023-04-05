require_relative "./prelude"
using ChapterHelpers

class User < ApplicationRecord
  self.table_name = "bit_users"

  NOTIFICATION_BITS = {
    all: 1,
    email: 3,
    sms: 5
  }.freeze

  def notifications_enabled? =
    (notification_bits & 1 == 1)

  def email_notifications_enabled? =
    (notification_bits & 3 == 3)

  def sms_notifications_enabled? =
    (notification_bits & 5 == 5)
end

u1 = User.new(notification_bits: User::NOTIFICATION_BITS[:email])
u1.notifications_enabled?

u1.email_notifications_enabled?

u1.sms_notifications_enabled?

u2 = User.new(notification_bits: User::NOTIFICATION_BITS[:sms])
u2.notifications_enabled?

u2.email_notifications_enabled?

u2.sms_notifications_enabled?

# Adding a value object
class User::Notifications
  BITS = {
    all: 1,
    email: 3,
    sms: 5
  }.freeze

  private attr_reader :val
  def initialize(value) = @val = value

  def enabled? = (val & 1 == 1)

  def email? = (val & 3 == 3)

  def sms? = (val & 5 == 5)
end

class User < ApplicationRecord
  def notifications =
    @notifications ||=
      Notifications.new(notification_bits)
end

u1.notifications.enabled?

u1.notifications.email?

u1.notifications.sms?
