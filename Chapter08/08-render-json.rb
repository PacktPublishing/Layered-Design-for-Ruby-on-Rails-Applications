require_relative "./prelude"
using ChapterHelpers

user = User.create!(name: "J Son")
post = Post.create!(title: "Serialize all the things", user:)

class PostsController < ApplicationController
  def show
    post = Post.find(params[:id])
    render json: post
  end
end

response = get "/posts/#{post.id}"
puts response.body

class Post < ApplicationRecord
  belongs_to :user
  def as_json(options)
    super({
      only: [:id, :title, :draft],
      include: {user: {only: [:id, :name]}}
    }.merge(options))
  end
end

response = get "/posts/#{post.id}"
puts response.body

class PostsController < ApplicationController
  def show
    post = Post.find(params[:id])
    render json: post.as_json({only: [:id]})
  end
end

response = get "/posts/#{post.id}"
puts response.body
