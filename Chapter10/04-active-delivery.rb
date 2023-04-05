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

class ApplicationDelivery < ActiveDelivery::Base
  before_notify :ensure_enabled
  before_notify :ensure_mailer_enabled, on: :mailer

  def ensure_enabled = !!user&.notifications_enabled?

  def ensure_mailer_enabled
    !!user&.email_notifications_enabled?
  end

  def user = params[:user]
end

class PostDelivery < ApplicationDelivery
  delivers :published
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
    post.user.subscribers.each do |user|
      PostDelivery.with(user:)
        .published(post).deliver_later
    end
  end
end

Post::Publish.call(rails_post)

# Adding SMS notifier
class ApplicationSMSNotifier < AbstractNotifier::Base
  self.driver = proc do |data|
    data => {to:, body:}
    SMSSender.new(to).send_now(body:)
  end

  private def user = params[:user]
end

class PostSMSNotifier < ApplicationSMSNotifier
  def published(post)
    notification(
      to: user.phone_number,
      body: "Post has been published: #{post.title}"
    )
  end
end

class ApplicationDelivery < ActiveDelivery::Base
  register_line :sms, notifier: true, suffix: "SMSNotifier"
  before_notify :ensure_sms_enabled, on: :sms

  private

  def ensure_sms_enabled
    !!user&.sms_notifications_enabled?
  end
end

# Reset memoized lines to use the new one:
PostDelivery.remove_instance_variable(:@lines) # :ignore:

new_post = Post.create!(title: "Ruby on Rails returns", user: author)

Post::Publish.call(new_post)

# Testing deliveries and notifiers

require_relative "rails_helper"

RSpec.describe Post::Publish do
  let(:user) { User.create!(name: "Author", email: "author@ex.test") }
  let(:post) { Post.create!(title: "Test", user: author) }
  let!(:subscriber) do
    User.create!(name: "Tester", email: "a@ex.test").tap { post.user.subscribers << _1 }
  end

  subject { described_class.call(post) }

  it "triggers delivery to subscribers," do
    expect { subject }.to have_delivered_to(
      PostDelivery, :published, post
    ).with(
      user: subscriber
    )
  end
end

RSpec.describe PostDelivery do
  let(:user) { User.new(phone_number: "311") }
  let(:delivery) { described_class.with(user:) }

  describe "#published" do
    let(:post) { Post.new(title: "A") }
    subject { delivery.published(post).deliver_now }

    it "notifies via SMS" do
      expect { subject }.to have_sent_notification(
        via: PostSMSNotifier,
        to: "311",
        body: "Post has been published: A"
      )
    end
  end
end

RSpec::Core::Runner.run([])
