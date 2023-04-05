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

class ApplicationNotifier < ApplicationService
  class << self
    def plug(delivery_method, **options)
      plugins << [delivery_method, options]
    end

    # FIXME: Doesn't support inheritance
    def plugins = @plugins ||= []
  end

  def notify(user, ...)
    plugins.each { _1.notify(user, ...) }
  end

  private

  def plugins
    self.class.plugins.filter_map do |id, opts|
      plugin_class = "#{id.to_s.classify}NotifierPlugin".safe_constantize
      next unless plugin_class

      plugin_class.new(**opts)
    end
  end
end

class MailerNotifierPlugin
  attr_reader :class_name, :action

  def initialize(class_name:, action:)
    @class_name, @action = class_name, action
  end

  def notify(user, ...)
    return unless user.notifications_enabled? &&
      user.email_notifications_enabled?

    mailer = class_name.constantize.with(user:)
    mailer.public_send(action, ...).deliver_later
  end
end

class Post::NotifyPublished < ApplicationNotifier
  plug :mailer, class_name: "PostMailer",
    action: "published"
  plug :sms, content: ->(post) { "Post has been published: #{post.title}" }
  plug :cable, event: "post.published",
    payload: ->(post) { post.slice(:id, title) }

  param :post

  def call
    post.user.subscribers.each { notify(_1, post) }
  end
end

Post::NotifyPublished.call(post)
