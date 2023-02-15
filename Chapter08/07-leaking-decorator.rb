require_relative "./prelude"
using ChapterHelpers

ruby = User.create!(name: "Ruby Crystal")
crystal_post = Post.create!(title: "Crystal for Rubyists", user: ruby)

class PostPresenter < SimpleDelegator
end

class ApplicationController
  def present(obj, with: nil)
    presenter_class = with ||
      "#{obj.class.name}Presenter".constantize
    presenter_class.new(obj)
  end
end

module Analytics
  def self.track_event(name, obj)
    puts "event=#{name} id=#{obj.id} class=#{obj.class}"
  end
end

class PostsController < ApplicationController
  before_action :set_post, only: [:show]

  def show
    Analytics.track_event("post.viewed", @post)
  end

  private

  def set_post = @post = present(Post.find(params[:id]))
end

get "/posts/#{crystal_post.id}"
