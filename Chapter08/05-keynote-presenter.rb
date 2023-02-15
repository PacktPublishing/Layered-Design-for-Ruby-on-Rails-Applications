require_relative "./prelude"
using ChapterHelpers

ruby = User.create!(name: "Ruby Crystal")
david = User.create!(name: "David Heinemeier Hansson")

crystal_post = Post.create!(title: "Crystal for Rubyists", user: ruby)
rails_post = Post.create!(title: "Rails is the way", draft: false, user: david)

class UserPresenter < Keynote::Presenter
  presents :user

  def short_name
    user.name.squish.split(/\s/).then do |parts|
      parts[0..-2].map { _1[0] + "." }.join + parts.last
    end
  end
end

class PostPresenter < Keynote::Presenter
  presents :post

  def status_icon
    if post.draft?
      "fa-hourglass-start"
    else
      "fa-calendar-check"
    end
  end
end

response = get "/posts"
puts response.body
