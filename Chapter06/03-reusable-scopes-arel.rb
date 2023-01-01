require_relative "./prelude"

# Populate data
user = User.create!(name: "Vova")
alice = User.create!(name: "Alice")
post = Post.create!(title: "Query Objects on Rails", tags: ["rails", "active_record"])
post_2 = Post.create!(title: "Reusable Query Objects on Rails with Arel", tags: ["rails", "arel"])
user.bookmarks.create!(post:, tags: %w[ruby todo])
user.bookmarks.create!(post: post_2, tags: %w[unsorted])
alice.bookmarks.create!(post: post_2, tags: %w[ruby sql])

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

class Bookmark
  # Add human-readable string representation
  # for demonstration purposes
  def inspect
    "#{user.name} bookmarked post #{post.title} (##{post.id}) with tags: #{tags&.join(", ") || "none"}"
  end
end

class Post < ApplicationRecord
  scope :tagged, ->(tag) {
    where("EXISTS (SELECT 1 FROM json_each(tags) WHERE value = ?)", tag)
  }
end

Post.tagged("rails")

class Bookmark < ApplicationRecord
  scope :tagged, ->(tags) {
    where("EXISTS (SELECT 1 FROM json_each(tags) WHERE value = ?)", tags)
  }
end

user.bookmarks.tagged("ruby")

class TaggedQuery < ApplicationQuery
  def resolve(tag)
    relation.where("EXISTS (" \
      "SELECT 1 FROM json_each(tags) WHERE value = ?" \
    ")", tag)
  end
end

# For posts
TaggedQuery.new(Post.all).resolve("rails")

# For bookmarks
TaggedQuery.new(user.bookmarks).resolve("ruby")

class ApplicationQuery
  class << self
    attr_writer :query_model_name

    def query_model_name
      @query_model_name ||= name.sub(/::[^:]+$/, "")
    end

    def query_model
      query_model_name.safe_constantize
    end

    def [](model)
      Class.new(self).tap { _1.query_model_name = model.name }
    end
  end
end

class Post < ApplicationRecord
  scope :tagged, TaggedQuery[self]
end

class Bookmark < ApplicationRecord
  scope :tagged, TaggedQuery[self]
end

Post.tagged("rails")

user.bookmarks.tagged("ruby")

class User < ApplicationRecord
  has_many :bookmarked_posts, through: :bookmarks, source: :post
end

begin
  user.bookmarked_posts.tagged("rails").pluck(:title)
rescue => e
  puts "#{e.class}: #{e.message}"
end

class TaggedQuery < ApplicationQuery
  def resolve(tag)
    relation.where("EXISTS (" \
      "SELECT 1 FROM
       json_each(#{relation.table_name}.tags)
       WHERE value = ?" \
    ")", tag)
  end
end

puts user.bookmarked_posts.tagged("rails").pluck(:title)

puts user.bookmarked_posts.tagged("arel").pluck(:title)

class TaggedQuery < ApplicationQuery
  def resolve(tag)
    # SELECT 1 FROM json_each(tags) WHERE value in (...)
    tags_subquery = tags_table.project(1).where(tags_table[:value].eq(tag))

    relation.where(tags_subquery.exists)
  end

  private

  def tags_table
    @tags_arel ||= Arel::Nodes::NamedFunction.new("json_each", [arel_table[:tags]]).then do
      name = Arel.sql(_1.to_sql)
      Arel::Table.new(name, as: :json_tags)
    end
  end

  def arel_table = self.class.query_model.arel_table
end

Bookmark.tagged("sql")
