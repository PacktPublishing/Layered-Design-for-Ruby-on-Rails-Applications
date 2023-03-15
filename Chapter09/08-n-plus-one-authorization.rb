require_relative "./prelude"
using ChapterHelpers

class User
  has_many :posts

  enum :role, regular: "regular", admin: "admin",
    librarian: "librarian"
end

class PostPolicy < ApplicationPolicy
  # Assuming that there is a limit on the number of drafts
  def publish? = user.admin? || (
    (user.id == post.user_id) && user.posts.where(published_at: nil).size < 20
  )

  def manage? = user.admin? || (user.id == post.user_id)
end

# Generate data
user = User.create!(name: "Vova")
admin = User.admin.create!(name: "Admin")

40.times { Post.create!(title: "Post ##{_1}", user:) }

posts = Post.all.to_a

template = <<~ERB # :ignore:output
  <%- posts.each do |post| %>
    <div>
      <%= link_to post.title, post %>
      <% if allowed_to?(:publish?, post) %>
        <%= button_to "Publish", publish_post_path(post), method: :patch %>
      <% end %>
      <% if allowed_to?(:edit?, post) %>
        <%= link_to "Edit", edit_post_path(post) %>
      <% end %>
      <% if allowed_to?(:destroy?, post) %>
        <%= button_to "Delete", post, method: :delete %>
      <% end %>
    </div>
  <% end %>
ERB

# Enable view logger to show runtime metrics
ActionView::Base.logger = ActiveSupport::Logger.new($stdout) # :ignore:

Current.set(user:) do
  ApplicationController.render(
    locals: {posts:},
    inline: template
  )
end

Current.set(user: admin) do
  ApplicationController.render(
    locals: {posts:},
    inline: template
  )
end
