require_relative "./prelude"
using ChapterHelpers

class User < ApplicationRecord
  enum :role, regular: "regular", admin: "admin",
    librarian: "librarian"
  enum :dept, fic: "fic", nonfic: "nonfic",
    ref: "ref"

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

class Book < ApplicationRecord
  enum :dept, fic: "fic", nonfic: "nonfic",
    ref: "ref"
end

# Populating data
librarian = User.librarian.ref.create!(name: "Book Keeper")
fic_librarian = User.librarian.fic.create!(name: "Fiction Keeper")
fic_book = Book.fic.create!(title: "Python on Rails", author: "Unknown")

class BookPolicy
  attr_reader :user, :book
  def initialize(user, book)
    @user, @book = user, book
  end

  def destroy?
    user.permission?(:manage_all_books) || (
      user.permission?(:manage_books) &&
      book.dept == user.dept
    )
  end
end

class BooksController < ApplicationController
  def destroy
    book = Book.find(params[:id])
    if BookPolicy.new(current_user, book).destroy?
      book.destroy!
      redirect_to books_path, notice: "Removed"
    else
      redirect_to books_path, alert: "No access"
    end
  end
end

response = delete "/books/#{fic_book.id}", cookies: {user_id: librarian.id}
puts [response.status, response.flash]

Book.where(id: fic_book.id).exists?

response = delete "/books/#{fic_book.id}", cookies: {user_id: fic_librarian.id}
puts [response.status, response.flash]

Book.where(id: fic_book.id).exists?
