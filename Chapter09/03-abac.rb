require_relative "./prelude"
using ChapterHelpers

class User < ApplicationRecord
  enum :role, regular: "regular", admin: "admin",
    librarian: "librarian"

  REGULAR_PERMISSIONS = %i[
    browse_catalogue borrow_books
  ].freeze

  LIBRARIAN_PERMISSIONS = (
    REGULAR_PERMISSIONS + %i[manage_books]
  ).freeze

  ADMIN_PERMISSIONS = (
    LIBRARIAN_PERMISSIONS + %i[manage_librarians manage_all_books]
  ).freeze

  PERMISSIONS = {
    regular: REGULAR_PERMISSIONS,
    librarian: LIBRARIAN_PERMISSIONS,
    admin: ADMIN_PERMISSIONS
  }.freeze

  def permission?(name) =
    PERMISSIONS.fetch(role.to_sym)
      .include?(name)
end

# Add departments
class User < ApplicationRecord
  enum :dept, fic: "fic", nonfic: "nonfic",
    ref: "ref"
end

class Book < ApplicationRecord
  enum :dept, fic: "fic", nonfic: "nonfic",
    ref: "ref"
end

class BooksController < ApplicationController
  def destroy
    book = Book.find(params[:id])
    if current_user.permission?(:manage_all_books) || (
      current_user.permission?(:manage_books) &&
      book.dept == current_user.dept
    )
      book.destroy!
      redirect_to books_path, notice: "Removed"
    else
      redirect_to books_path, alert: "No access"
    end
  end
end

# Populating data
admin = User.admin.create!(name: "Admin")
librarian = User.librarian.ref.create!(name: "Book Keeper")
reader = User.regular.create!(name: "George")
fic_book = Book.fic.create!(title: "Python on Rails", author: "Unknown")

response = delete "/books/#{fic_book.id}", cookies: {user_id: reader.id}
puts [response.status, response.flash]

Book.where(id: fic_book.id).exists?

response = delete "/books/#{fic_book.id}", cookies: {user_id: librarian.id}
puts [response.status, response.flash]

Book.where(id: fic_book.id).exists?

response = delete "/books/#{fic_book.id}", cookies: {user_id: admin.id}
puts [response.status, response.flash]

Book.where(id: fic_book.id).exists?
