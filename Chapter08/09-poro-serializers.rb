require_relative "./prelude"
using ChapterHelpers

ruby = User.create!(name: "Ruby Crystal")
david = User.create!(name: "David Heinemeier Hansson")

crystal_post = Post.create!(title: "Crystal for Rubyists", user: ruby)
rails_post = Post.create!(title: "Rails is the way", draft: false, user: david)

class UserPresenter < SimpleDelegator
  def short_name
    name.squish.split(/\s/).then do |parts|
      parts[0..-2].map { _1[0] + "." }.join + parts.last
    end
  end

  def as_json(...)
    {id:, short_name:}
  end
end

class PostPresenter < SimpleDelegator
  def as_json(...)
    {
      id:, title:,
      is_draft: draft?,
      user: UserPresenter.new(user)
    }
  end
end

class PostsController < ApplicationController
  def index
    render json: Post.all.map { PostPresenter.new(_1) }
  end
end

response = get "/posts"
puts response.body
