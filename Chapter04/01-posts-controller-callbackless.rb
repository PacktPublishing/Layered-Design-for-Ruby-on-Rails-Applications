require_relative "./prelude.rb"
using ChapterHelpers

class PostsController < ApplicationController
  def show
    authenticate!

    @post = Post.find(params[:id])
    track_post_view
  end

  def update
    authenticate!

    @post = Post.find(params[:id])

    if @post.update(post_params)
      redirect_to @post
    else
      render action: :edit
    end
  end

  private

  def track_post_view
    # e.g., enqueue a background job from here
  end

  def post_params = params.require(:post).permit(:title, :content)
end

post = Post.create!(title: "Layering Rails", content: "Rails is a framework")

patch "/posts/#{post.id}", params: {post: {content: "Rails is an onion"}}

puts post.reload.content
