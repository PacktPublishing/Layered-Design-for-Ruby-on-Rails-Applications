require_relative "./prelude"
using ChapterHelpers

class PostsController < ApplicationController
  before_action :authenticate!
  before_action :load_post, only: [:show, :update]
  after_action :track_post_view, only: [:show]

  def update
    if @post.update(post_params)
      redirect_to @post
    else
      render action: :edit
    end
  end

  private

  def load_post = @post = Post.find(params[:id])

  def track_post_view
    # e.g., enqueue a background job from here
  end

  def post_params = params.require(:post).permit(:title, :content)
end

post = Post.create!(title: "Layering Rails", content: "Rails is a framework")

patch "/posts/#{post.id}", params: {post: {content: "Rails is an onion"}}

puts post.reload.content
