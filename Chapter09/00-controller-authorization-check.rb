require_relative "./prelude"
using ChapterHelpers

# Populating data
user = User.create!(name: "Vova")
alice = User.create!(name: "Alice")
post = Post.create(user:, title: "Authorization != authentication")

class PostsController < ApplicationController
  before_action :authenticate! # authentication

  def destroy
    post = Post.find(params[:id])
    if post.user_id == current_user.id # authorization
      # context has been validated,
      # feel free to perform the action
      post.destroy
      redirect_to posts_path, notice: "Post has been deleted"
    else
      redirect_to posts_path, alert: "You are not allowed to delete this post"
    end
  end
end

response = delete "/posts/#{post.id}", cookies: {user_id: alice.id}
puts response.flash

Post.where(id: post.id).exists?

response = delete "/posts/#{post.id}", cookies: {user_id: user.id}
puts response.flash

Post.where(id: post.id).exists?
