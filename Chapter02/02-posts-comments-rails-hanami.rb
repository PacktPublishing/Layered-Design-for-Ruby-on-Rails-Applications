require_relative "./prelude"

# Active Record models
class User < ApplicationRecord
  has_many :posts, -> { order(id: :desc) }
end

class Post < ApplicationRecord
  has_many :comments, -> { order(id: :desc) }
end

class Comment < ApplicationRecord
end

# Populate demo data
user = User.create!(name: "Vova")
post_rails = user.posts.create!(title: "Rails 7.0 released!")
post_hanami = user.posts.create!(title: "Hanami 2.0 is out!")
Comment.insert_all([
  {body: "Still rocks", user_id: user.id, post_id: post_rails.id},
  {body: "All my life I've been waiting for something", user_id: user.id, post_id: post_hanami.id}
]) # :ignore:output

# Show the top-3 latest comments for the latest user’s post
user.posts.first.comments.limit(3)

# Hanami repositiries
class PostRepository < Hanami::Repository
  associations do
    has_many :comments
  end

  def latest_for_user(user_id)
    posts.where(user_id:).order { id.desc }.limit(1).one
  end
end

class CommentRepository < Hanami::Repository
  def latest_for_post(post_id, count:)
    comments.where(post_id:)
      .order { id.desc }
      .limit(count).to_a
  end
end

# Fetching the user's latest post first
latest_post = PostRepository.new.latest_for_user(user.id)

# Then, fetching comments
latest_comments = CommentRepository.new.latest_for_post(latest_post.id, count: 3)
