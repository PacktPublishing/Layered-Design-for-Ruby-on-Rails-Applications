require_relative "./prelude"

class Post < ApplicationRecord
  validate :prevent_drafting_published,
    if: -> { published? && will_save_change_to_draft? }

  validates :title, presence: true

  def prevent_drafting_published
    errors.add(:base, "Switching back to draft is not allowed for published posts")
  end
end

post = Post.create!(title: "The Rails 4 Way", published: true)

post.update(draft: true)

puts post.errors.full_messages
