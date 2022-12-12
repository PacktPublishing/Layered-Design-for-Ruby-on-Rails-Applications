require_relative "./prelude"

class ApplicationController < ActionController::Base
  before_action :authenticate!

  private

  def authenticate!
    current_user || redirect_to(login_path)
  end

  def current_user
    @current_user ||= User.find_by(id: params[:user_id])
  end
end

class PostsController < ApplicationController
  before_action :load_post
  skip_before_action :authenticate!, only: [:show]

  def show
    authenticate! unless @post.is_public?
  end

  private

  def load_post = @post = Post.find(params[:id])
end

user = User.create!(name: "Vova")
post = Post.create!(title: "Layering Rails 2", content: "Rails is more than a framework", is_public: false)

# Authenticated request
response = get "/posts/#{post.id}?user_id=#{user.id}"
puts response.body

# Unauthenticated request
response = get "/posts/#{post.id}"
puts response.body

# Add new application-level callback relying on the authencation
class ApplicationController
  after_action :track_page_view

  private

  def track_page_view
    current_user.track_page_view!(request.path)
  end
end

# Authenticated request succeeds as before
response = get "/posts/#{post.id}?user_id=#{user.id}"
puts response.body

# Unauthenticated request now raises an exception
get "/posts/#{post.id}"
