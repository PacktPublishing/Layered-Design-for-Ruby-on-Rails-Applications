require_relative "./prelude"

# We need to initialize class first to
# use it as a namespace for validator
class Post < ApplicationRecord # :ignore:
end

class Post::PublishingValidator < ActiveModel::Validator
  def validate(post)
    return unless post.published?

    validate_publish_date(post)
    validate_author(post)
    # … more validations related to post publishing
  end

  def validate_publish_date(post)
    unless post.publish_date.present?
      return post.errors.add(:publish_date, :blank)
    end

    # Assuming we only publish posts on Tuesdays
    if post.publish_date.wday != 1
      post.errors.add(:publish_date, :not_tuesday)
    end
  end

  def validate_author(post)
    post.errors.add(:author, :blank) unless post.author
  end
end

class Post < ApplicationRecord
  validates_with PublishingValidator, on: :publish

  enum :status, {draft: "draft", published: "published"}

  def publish
    self.status = :published
    save!(context: :publish)
  end
end

post = Post.create!(title: "The Rails 5 Way")

# Post without author and publish date
post.publish

post.author = "Vova"
# Published on Tue
post.publish_date = Date.new(2022, 12, 13)
post.publish
