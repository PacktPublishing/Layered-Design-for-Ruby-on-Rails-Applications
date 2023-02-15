require_relative "./prelude"
using ChapterHelpers

user = User.create!(name: "Ruby Crystal")

class UserPresenter < SimpleDelegator
  def short_name
    name.squish.split(/\s/).then do |parts|
      parts[0..-2].map { _1[0] + "." }.join + parts.last
    end
  end
end

binding.render <<~ERB
  <%- user = UserPresenter.new(user) -%>
  <div id="user-<%= user.id %>">
    <%= link_to user.short_name, user %>
  </div>
ERB
