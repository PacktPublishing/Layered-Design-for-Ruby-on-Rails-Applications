require_relative "./prelude"
using ChapterHelpers

ruby = User.create!(name: "Ruby Crystal")
david = User.create!(name: "David Heinemeier Hansson")

crystal_post = Post.create!(title: "Crystal for Rubyists", user: ruby)
rails_post = Post.create!(title: "Rails is the way", draft: false, user: david)

module UsersHelper
  def user_short_name(user)
    user.name.squish.split(/\s/).then do |parts|
      parts[0..-2].map { _1[0] + "." }.join + parts.last
    end
  end
end

module PostsHelper
  def post_icon(post)
    if post.draft?
      "fa-hourglass-start"
    else
      "calendar-check"
    end
  end

  def post_author(post) = user_short_name(post.user)
end

# Register heleprs manually (Rails loads them from app/helpers) # :ignore:
ApplicationController.helper UsersHelper
ApplicationController.helper PostsHelper

response = get "/posts"
puts response.body
