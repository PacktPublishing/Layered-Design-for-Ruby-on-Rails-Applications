require_relative "./prelude"

# Populating data
account = Account.create!(name: "Any Rails")
user = account.users.create(name: "Vova")
alice = account.users.create(name: "Alice")
post = alice.posts.create(title: "Query Objects on Rails", created_at: Time.current.prev_week)
user.bookmarks.create!(post:)

Post.insert_all([
  {title: "A", created_at: 1.day.ago},
  {title: "B", created_at: 1.hour.ago}
])

class Post < ApplicationRecord
  scope :ordered, -> { order(created_at: :desc) }
  scope :published, -> { where(draft: false) }
end

Post.published.order(title: :asc).pluck(:title)

# Adding .ordered to the .published scope
class Post < ApplicationRecord
  scope :ordered, -> { order(created_at: :desc) }
  scope :published, -> { ordered.where(draft: false) }
end

Post.published.order(title: :asc).pluck(:title)

# Query objects vs scopes
class User < ApplicationRecord
  def self.with_bookmarked_posts(period = :previous_week)
    bookmarked_posts =
      Post.public_send(period)
        .where.associated(:bookmarks)
        .select(:user_id).distinct
    with(bookmarked_posts:).joins(:bookmarked_posts)
  end
end

# Add Post scopes
class Post < ApplicationRecord
  scope :previous_week, -> {
    where(created_at: Date.current.prev_week.all_week)
  }
  scope :previous_month, -> {
    where(created_at: Date.current.prev_month.all_month)
  }
end

class ApplicationQuery
  class << self
    def query_model
      name.sub(/::[^:]+$/, "").safe_constantize
    end

    def resolve(...) = new.resolve(...)

    alias_method :call, :resolve
  end

  private attr_reader :relation

  def initialize(relation = self.class.query_model.all)
    @relation = relation
  end

  def resolve(...) = relation
end

class User::WithBookmarkedPostsQuery < ApplicationQuery
  def resolve(period: :previous_week)
    bookmarked_posts = build_bookmarked_posts_scope(period)
    relation.with(bookmarked_posts:).joins(:bookmarked_posts)
  end

  private

  def build_bookmarked_posts_scope(period)
    return Post.none unless Post.respond_to?(period)

    Post.public_send(period)
      .where.associated(:bookmarks)
      .select(:user_id).distinct
  end
end

account.users.with_bookmarked_posts

User::WithBookmarkedPostsQuery.new(account.users).resolve

# Make sure the class method is no longer defined
User.singleton_class.remove_method :with_bookmarked_posts

class User < ApplicationRecord
  scope :with_bookmarked_posts, WithBookmarkedPostsQuery
end

account.users.with_bookmarked_posts
