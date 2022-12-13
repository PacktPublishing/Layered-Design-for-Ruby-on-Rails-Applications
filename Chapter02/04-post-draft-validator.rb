require_relative "./prelude"

# We need to initialize class first to
# use it as a namespace for validator
class Post < ApplicationRecord # :ignore:
end

class Post::DraftValidator < ActiveModel::Validator
  def validate(post)
    return unless post.published?
    return unless post.will_save_change_to_draft?

    post.errors.add(:base, "Switching back to draft is not allowed for published posts")
  end
end

class Post < ApplicationRecord
  validates_with DraftValidator
end

post = Post.create!(title: "The Rails 5 Way", published: true)

post.update(draft: true)

puts post.errors.full_messages
