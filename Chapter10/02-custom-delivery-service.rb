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

class Post::NotifyPublished < ApplicationService
  param :post

  def call
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

class Post
  class Publish < ApplicationService
    param :post

    def call
      post.update!(
        published_at: Time.current,
        status: :published
      )

      NotifyPublished.call(post)
    end
  end
end

Post::Publish.call(post)

require_relative "rails_helper"

RSpec.describe Post::Publish do
  let(:post) { Post.create!(title: "Test") }

  subject { described_class.call(post) }

  before { allow(Post::NotifyPublished).to receive(:call) }

  it "marks the post as published and sets published_at" do
    subject
    expect(post.reload.published_at).not_to be_nil
    expect(post).to be_published
  end

  it "triggers notification via NotifyPublished" do
    subject
    expect(Post::NotifyPublished)
      .to have_received(:call).with(post)
  end
end

RSpec::Core::Runner.run([])
