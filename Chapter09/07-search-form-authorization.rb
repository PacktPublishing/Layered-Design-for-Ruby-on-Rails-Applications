require_relative "./prelude"
using ChapterHelpers

class User < ApplicationRecord
  enum :role, regular: "regular", admin: "admin",
    librarian: "librarian"
end

module Books
  class SearchForm < ApplicationForm
    attribute :q
    attribute :isbn
    attribute :book_id
  end
end

# Populating data
reader = User.regular.create!(name: "Vova")
librarian = User.librarian.create!(name: "Book Keeper")
admin = User.admin.create!(name: "Library Admin")

template = <<~ERB # :ignore:output
  <%= form_for Books::SearchForm.new do |f| %>
    <%= f.text_field :q, placeholder: "Type a query.." %>
  <%- if current_user.librarian? || current_user.admin? -%>
    <%= f.text_field :isbn, placeholder: "ISNB" %>
  <%- end -%>
  <%- if current_user.admin? -%>
    <%= f.text_field :book_id, placeholder: "Book ID" %>
  <%- end -%>
  <% end %>
ERB

Current.set(user: reader) do
  binding.render(template)
end

Current.set(user: librarian) do
  binding.render(template)
end

Current.set(user: admin) do
  binding.render(template)
end

# Migrating to policies
class BookPolicy < ApplicationPolicy
  def search_by_isbn? = user.librarian? || user.admin?

  def search_by_id? = user.admin?
end

template = <<~ERB # :ignore:output
  <%= form_for Books::SearchForm.new do |f| %>
    <%= f.text_field :q, placeholder: "Type a query.." %>
  <%- if allowed_to?(:search_by_isbn?, Book) -%>
    <%= f.text_field :isbn, placeholder: "ISNB" %>
  <%- end -%>
  <%- if allowed_to?(:search_by_id?, Book) -%>
    <%= f.text_field :book_id, placeholder: "Book ID" %>
  <%- end -%>
  <% end %>
ERB

Current.set(user: reader) do
  binding.render(template)
end

Current.set(user: librarian) do
  binding.render(template)
end

Current.set(user: admin) do
  binding.render(template)
end

# Policy with the filtered params list
class BookPolicy < ApplicationPolicy
  def search_params
    [].tap do
      _1 << :isbn if user.admin? || user.librarian?
      _1 << :book_id if user.admin?
    end
  end
end

template = <<~ERB # :ignore:output
  <%- policy = BookPolicy.new(user: current_user) -%>
  <%= form_for Books::SearchForm.new do |f| %>
    <%= f.text_field :q, placeholder: "Type a query.." %>
  <%- if policy.search_params.include?(:isbn) -%>
    <%= f.text_field :isbn, placeholder: "ISNB" %>
  <%- end -%>
  <%- if policy.search_params.include?(:book_id) -%>
    <%= f.text_field :book_id, placeholder: "Book ID" %>
  <%- end -%>
  <% end %>
ERB

Current.set(user: reader) do
  binding.render(template)
end

Current.set(user: librarian) do
  binding.render(template)
end

Current.set(user: admin) do
  binding.render(template)
end

# Proposed interface for authorization integrated into form objects
<<~ERB # :ignore:output
  <% search_form = Books::SearchForm.new %>
  <%= form_for search_form do |f| %>
    <%= f.text_field :q, placeholder: "Type a query.." %>
    <% if search_form.field_allowed?(:isbn) %>
      <%= f.text_field :isbn, placeholder: "ISNB" %>
    <% end %>
    <% if search_form.field_allowed?(:book_id) %>
      <%= f.text_field :book_id, placeholder: "Book ID" %>
    <% end %>
  <% end %>
ERB
