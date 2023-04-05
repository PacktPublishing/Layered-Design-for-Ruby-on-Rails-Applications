require_relative "./prelude"
using ChapterHelpers

# Populating data
author = User.create!(name: "Vova", email: "me@example.test")
alice = User.create!(
  name: "Alice",
  email: "alice@example.test",
  phone_number: "+1 234 567-8900",
  notifications_enabled: true,
  email_notifications_enabled: true,
  sms_notifications_enabled: true
)
rails_post = Post.create!(title: "A slice of Rails", user: author)
author.subscribers << alice

class SMSDelivery < Noticed::DeliveryMethods::Base
  def deliver
    notification.sms_params => {to:, body:}
    SMSSender.new(to).send_now(body:)
  end
end

class PostMailer < ApplicationMailer
  def published
    @post = params[:post]
    @user = params[:recipient]
    mail(
      to: @user.email,
      subject: "A new post has been published!",
      body: "Check out #{@post.title}!"
    )
  end
end

class PostPublishedNotification < Noticed::Base
  deliver_by :email, mailer: "PostMailer",
    method: :published, if: :email?

  deliver_by :sms, class: "SMSDelivery", if: :sms?
  deliver_by :action_cable, channel: "NotificationsChannel", format: :cable_payload

  def cable_payload =
    post.slice(:id, :title).merge(
      event: "post.published"
    )

  def sms_params =
    {
      to: user.phone_number,
      body: "Post has been published: #{post.title}"
    }

  private

  alias_method :user, :recipient
  def post = params[:post]

  def email? = user.notifications_enabled? &&
    user.email_notifications_enabled?

  def sms? = user.notifications_enabled? &&
    user.sms_notifications_enabled?
end

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
    PostPublishedNotification.with(post:).deliver_later(
      post.user.subscribers
    )
  end
end

Post::Publish.call(rails_post)
