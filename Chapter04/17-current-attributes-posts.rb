require_relative "./prelude"
using ChapterHelpers

class Current < ActiveSupport::CurrentAttributes
  attribute :user
end

class ApplicationController < ActionController::Base
  before_action :set_current_user

  private

  def set_current_user
    Current.user = User.find_by(id: cookies[:user_id])
  end
end

# Phase 1: Soft-deleting posts and storing the information about the
# deleter user
class PostsController < ApplicationController
  def destroy
    post = Post.find(params[:id])
    post.destroy!
    redirect_to posts_path
  end
end

class Post < ApplicationRecord
  include Discard::Model
  self.discard_column = :deleted_at

  belongs_to :deleted_by, class_name: "User",
                          optional: true

  def destroy
    self.deleted_by = Current.user
    discard
  end
end

user = User.create!(name: "Vova", email: "vova@example.com")

post = Post.create!(title: "To delete or not to delete", content: "Delete, please")

response = delete "/posts/#{post.id}", cookies: {user_id: user.id}
response.status

puts "Deleted by: #{post.reload.deleted_by&.name}"

# # Phase 2: Moving post.destroy to a background job
class PostsController < ApplicationController
  def destroy
    post = Post.find(params[:id])

    PostDeleteJob.perform_later(post)

    redirect_to posts_path
  end
end

class PostDeleteJob < ApplicationJob
  def perform(post) = post.destroy!
end

post = Post.create!(title: "Delete it again", content: "Delete, please")

response = delete "/posts/#{post.id}", cookies: {user_id: user.id}
response.status

puts "Deleted by: #{post.reload.deleted_by&.name}"

# Phase 3: Adding #destroy_all action to destroy multiple posts in a single request
class PostsController < ApplicationController
  def destroy_all
    Post.where(id: params[:ids]).destroy_all

    redirect_to posts_path
  end
end

# Adding email notifications after deletion
class Post < ApplicationRecord
  belongs_to :user
  belongs_to :deleted_by, class_name: "User",
                          optional: true

  after_discard :notify_author

  def destroy
    self.deleted_by = Current.user
    discard
  end

  private

  def notify_author
    Current.user = user

    PostMailer.notify_deleted(self).deliver_now
  end
end

# The mailer class uses Current.user as a target user
class PostMailer < ApplicationMailer
  default to: -> { Current.user&.email }

  def notify_deleted(post)
    mail(
      subject: "Post deleted: #{post.title}",
      body: "Deleted by #{post.deleted_by&.name}"
    )
  end
end

alice = User.create!(name: "Alice", email: "alice@example.com")
bob = User.create!(name: "Bob", email: "bob@example.com")

post_a = Post.create!(title: "Post A", content: "Delete, please", user: alice)
post_b = Post.create!(title: "Post B", content: "Delete, please", user: bob)

# Delete multiple post and see the emails being sent: they should both indicate that
# the posts were deleted by Vova, but...
response = delete "/posts?ids[]=#{post_a.id}&ids[]=#{post_b.id}", cookies: {user_id: user.id}
response.status

# Fix #1: Use Current.set(...) to avoid leaking global state
class Post < ApplicationRecord
  # ...

  private

  def notify_author
    Current.set(user:) do
      PostMailer.notify_deleted(self).deliver_now
    end
  end
end

post_a = Post.create!(title: "Post A", content: "Delete, please", user: alice)
post_b = Post.create!(title: "Post B", content: "Delete, please", user: bob)

# Now the deleted_by is set correctly and reflected in the emails
response = delete "/posts?ids[]=#{post_a.id}&ids[]=#{post_b.id}", cookies: {user_id: user.id}
response.status

# Fix #2: Pass user explicitly, avoid global state
class PostsController < ApplicationController
  def destroy_all
    Post.where(id: params[:ids]).each { _1.destroy_by(Current.user) }

    redirect_to posts_path
  end
end

class Post < ApplicationRecord
  def destroy_by(user = nil)
    self.deleted_by = user
    discard
  end

  private

  def notify_author
    PostMailer.notify_deleted(user, self).deliver_now
  end
end

class PostMailer < ApplicationMailer
  def notify_deleted(user, post)
    mail(
      to: user.email,
      subject: "Post deleted: #{post.title}",
      body: "Deleted by #{post.deleted_by&.name}"
    )
  end
end

post_c = Post.create!(title: "Post C", content: "Delete, please", user: alice)
post_d = Post.create!(title: "Post D", content: "Delete, please", user: bob)

# Now the deleted_by is set correctly and reflected in the emails
response = delete "/posts?ids[]=#{post_c.id}&ids[]=#{post_d.id}", cookies: {user_id: user.id}
response.status
