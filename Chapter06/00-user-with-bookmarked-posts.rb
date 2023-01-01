require_relative "./prelude"

# Populating data
user = User.create!(name: "Vova")
alice = User.create!(name: "Alice")
post = alice.posts.create(title: "Query Objects on Rails", created_at: Time.current.prev_week)
user.bookmarks.create!(post:)

Post.where(draft: false).order(created_at: :desc)

User.with(
  bookmarked_posts: Post
      .where(created_at: Date.current.prev_week.all_week)
      .where.associated(:bookmarks)
      .select(:user_id).distinct
).joins(:bookmarked_posts)

class Post < ApplicationRecord
  scope :ordered, -> { order(created_at: :desc) }
  scope :published, -> { where(draft: false) }
  scope :kept, -> { where(deleted_at: nil) }
  scope :previous_week, -> {
    where(created_at: Date.current.prev_week.all_week)
  }
end

# Now we use named scopes instead of explicit conditions
Post.kept.published.ordered

class User < ApplicationRecord
  def self.with_bookmarked_posts(period = :previous_week)
    bookmarked_posts =
      Post.public_send(period)
        .where.associated(:bookmarks)
        .select(:user_id).distinct
    with(bookmarked_posts:).joins(:bookmarked_posts)
  end
end

# Now we can use this query as follows
User.with_bookmarked_posts

# Extracting query into a separate object
class UserWithBookmarkedPostsQuery
  def call(period = :previous_week)
    bookmarked_posts =
      Post.public_send(period)
        .where.associated(:bookmarks)
        .select(:user_id).distinct
    User.with(bookmarked_posts:).joins(:bookmarked_posts)
  end
end

# Using query object
UserWithBookmarkedPostsQuery.new.call
