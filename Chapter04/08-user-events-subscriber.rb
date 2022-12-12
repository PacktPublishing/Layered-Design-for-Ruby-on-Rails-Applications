require_relative "./prelude"
using ChapterHelpers

class User < ApplicationRecord
  after_commit do
    ActiveSupport::Notifications.instrument(
      "updated.user",
      {user: self}
    )
  end
end

user = User.create!(name: "John")

class UserCRMSubscriber < ActiveSupport::Subscriber
  def updated(event)
    user = event.payload[:user]
    puts "User updated: #{user.name}"
  end
end

UserCRMSubscriber.attach_to :user

user.update!(name: "Vova")
