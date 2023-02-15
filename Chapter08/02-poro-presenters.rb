require_relative "./prelude"
using ChapterHelpers

user = User.create!(name: "Ruby Crystal")

class UserPresenter
  private attr_reader :user

  def initialize(user) = @user = user

  def short_name
    user.name.squish.split(/\s/).then do |parts|
      parts[0..-2].map { _1[0] + "." }.join + parts.last
    end
  end
end

binding.render <<~ERB
  <div id="user-<%= user.id %>">
    <%= link_to UserPresenter.new(user).short_name, user %>
  </div>
ERB

# Adding delegation
class UserPresenter
  delegate :id, :to_model, to: :user
end

binding.render <<~ERB
  <%- user = UserPresenter.new(user) -%>
  <div id="user-<%= user.id %>">
    <%= link_to user.short_name, user %>
  </div>
ERB
