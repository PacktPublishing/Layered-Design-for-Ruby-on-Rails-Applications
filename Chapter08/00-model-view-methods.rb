require_relative "./prelude"
using ChapterHelpers

class User < ApplicationRecord
  def short_name
    name.squish.split(/\s/).then do |parts|
      parts[0..-2].map { _1[0] + "." }.join + parts.last
    end
  end
end

ruby = User.create!(name: "Ruby Crystal")
david = User.create!(name: "David Heinemeier Hansson")

class Post < ApplicationRecord
  def status_icon
    "fa-#{draft? ? "hourglass-start" : "calendar-check"}"
  end

  def author_name = user&.short_name
end

crystal_post = Post.create!(title: "Crystal for Rubyists", user: ruby)
rails_post = Post.create!(title: "Rails is the way", draft: false, user: david)

puts crystal_post.status_icon

puts rails_post.author_name

response = get "/posts"
puts response.body
