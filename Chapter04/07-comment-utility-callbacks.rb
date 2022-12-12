require_relative "./prelude"
using ChapterHelpers

class Post
  has_many :comments, inverse_of: :post
end

class Comment < ApplicationRecord
  belongs_to :post, touch: true, counter_cache: true
end

post = Post.create!(title: "Rails is back", content: "Or is it?")

puts post.attributes.slice("comments_count", "updated_at")

# Add some sleep to see the #updated_at changes
sleep 1
post.comments.create(body: "Sure it is!")

# Reload record to reflect changes (e.g., updated_at)
puts post.reload.attributes.slice("comments_count", "updated_at")

# Re-create the Comment class and define the utility callbacks manually
remove_const(:Comment)

class Comment < ApplicationRecord
  belongs_to :post

  after_save { post.touch }

  after_create do
    Post.increment_counter(:comments_count, post_id)
  end

  after_destroy do
    Post.decrement_counter(:comments_count, post_id)
  end
end

# Add some sleep to see the #updated_at changes
sleep 1
post.comments.create(body: "Glad to hear that")

# Reload record to reflect changes (e.g., updated_at)
puts post.reload.attributes.slice("comments_count", "updated_at")
