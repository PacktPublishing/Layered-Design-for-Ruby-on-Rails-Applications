require_relative "./prelude"
using ChapterHelpers

# Populating data
user = User.create!(name: "Vova", email: "me@example.test")
alice = User.create!(
  name: "Alice",
  email: "alice@example.test",
  phone_number: "+1 234 567-8900",
  notifications_enabled: true,
  email_notifications_enabled: true,
  sms_notifications_enabled: true
)
post = Post.create!(title: "A slice of Rails", user:)
user.subscribers << alice

class Post::Publish < ApplicationService
  param :post

  def call
    post.update!(
      published_at: Time.current,
      status: :published
    )
    notify_subscribers
  end

  private

  def notify_subscribers
    post.user.subscribers.each do |user|
      next unless user.email_notifications_enabled?
      PostMailer.with(user:)
        .published(post).deliver_later
    end
  end
end

Post::Publish.call(post)

# Adding more notification channels
class Post::Publish
  def notify_subscribers
    payload = post.slice(:id, :title)
      .merge(event: "post.published")

    post.user.subscribers.each do |user|
      NotificationsChannel.broadcast_to(user, payload)
      next unless user.notifications_enabled?

      if user.email_notifications_enabled?
        PostMailer.with(user:)
          .published(post).deliver_later
      end

      if user.sms_notifications_enabled?
        SMSSender.new(user.phone_number).send_later(
          body: "Post has been published: #{post.title}"
        )
      end
    end
  end
end

new_post = Post.create!(title: "Ruby on Rails returns", user:)

Post::Publish.call(new_post)
