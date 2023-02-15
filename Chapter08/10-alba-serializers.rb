require_relative "./prelude"
using ChapterHelpers

ruby = User.create!(name: "Ruby Crystal")
david = User.create!(name: "David Heinemeier Hansson")

crystal_post = Post.create!(title: "Crystal for Rubyists", user: ruby)
rails_post = Post.create!(title: "Rails is the way", draft: false, user: david)

class ApplicationSerializer
  include Alba::Resource

  class << self
    def one(name, **options)
      options[:resource] ||= proc { |_obj| "#{name}Serializer".classify.constantize }
      super(name, **options)
    end
  end
end

class UserSerializer < ApplicationSerializer
  attributes :id, :short_name

  def short_name(user)
    user.name.squish.split(/\s/).then do |parts|
      parts[0..-2].map { _1[0] + "." }.join + parts.last
    end
  end
end

class PostSerializer < ApplicationSerializer
  attributes :id, :title
  attribute :is_draft, &:draft?

  one :user
end

class ApplicationController
  private

  def serialize(obj, with: nil)
    serializer = with || begin
      model = obj.try(:model) || obj.class
      "#{model.name}Serializer".constantize
    end

    serializer.new(obj)
  end
end

class PostsController < ApplicationController
  def index
    render json: serialize(Post.all)
  end
end

response = get "/posts"
puts response.body
