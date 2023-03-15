require_relative "./prelude"
using ChapterHelpers

class User < ApplicationRecord
  enum :role, regular: "regular", admin: "admin",
    librarian: "librarian"
  enum :dept, fic: "fic", nonfic: "nonfic",
    ref: "ref"
end

class Book < ApplicationRecord
  enum :dept, fic: "fic", nonfic: "nonfic",
    ref: "ref"
end

class BookPolicy < ApplicationPolicy
  def manage?
    user.admin? || (
      user.librarian? &&
        book.dept == user.dept
    )
  end
end

# Populating data
reader = User.regular.create!(name: "Vova")
librarian = User.librarian.ref.create!(name: "Book Keeper")
fic_librarian = User.librarian.fic.create!(name: "Fiction Keeper")
book = Book.fic.create!(title: "Python on Rails", author: "Unknown")

template = <<~ERB # :ignore:output
  <li>
    <%= book.title %>
    <% if allowed_to?(:destroy?, book) %>
      <%= button_to "Delete", book, method: :delete %>
    <% end %>
  </li>
ERB

Current.set(user: reader) do
  binding.render(template)
end

Current.set(user: librarian) do
  binding.render(template)
end

Current.set(user: fic_librarian) do
  binding.render(template)
end
