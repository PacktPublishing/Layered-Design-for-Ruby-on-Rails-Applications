require_relative "./prelude"

# Populating data
user = User.create!(name: "Vova")
alice = User.create!(name: "Alice")
post = alice.posts.create(title: "Query Objects on Rails", created_at: Time.current.prev_week)
user.bookmarks.create!(post:)
post_2 = user.posts.create(title: "Active Record scopes", created_at: Time.current.prev_month)
alice.bookmarks.create!(post: post_2)
post_3 = alice.posts.create(title: "Active Record models", created_at: Time.current.prev_week)
user.bookmarks.create!(post: post_3)

# Add Post scopes
class Post < ApplicationRecord
  scope :previous_week, -> {
    where(created_at: Date.current.prev_week.all_week)
  }
  scope :previous_month, -> {
    where(created_at: Date.current.prev_month.all_month)
  }
end

# 1. Query object basic interface: naming
class ApplicationQuery
  def resolve(...) = raise NotImplementedError
end

# 2. Query object basic interface: method signatures
class ApplicationQuery
  private attr_reader :relation
  def initialize(relation) = @relation = relation

  def resolve(...) = relation
end

class UserWithBookmarkedPostsQuery < ApplicationQuery
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

UserWithBookmarkedPostsQuery.new(User.all).resolve

UserWithBookmarkedPostsQuery.new(User.where(name: "Vova")).resolve

UserWithBookmarkedPostsQuery.new(User.where(name: "Vova")).resolve(period: :previous_month)

UserWithBookmarkedPostsQuery.new(User.all).resolve(period: :previous_month).where(name: "Vova")

class UserWithBookmarkedPostsQuery < ApplicationQuery
  def initialize(relation = User.all) = super(relation)
end

UserWithBookmarkedPostsQuery.new.resolve

class ApplicationQuery
  class << self
    def resolve(...) = new.resolve(...)
  end
end

UserWithBookmarkedPostsQuery.resolve

# 3. Inferring query model from a class name
class ApplicationQuery
  class << self
    def query_model
      name.sub(/::[^:]+$/, "").safe_constantize
    end
  end

  def initialize(relation = self.class.query_model.all)
    @relation = relation
  end
end

draft_post = Post.create!(title: "WIP", draft: true, user:)

class Post::DraftQuery < ApplicationQuery
  def resolve = relation.where(draft: true)
end

Post::DraftQuery.resolve
