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

# Populating data
admin = User.admin.create!(name: "Admin")
librarian = User.librarian.create!(name: "Book Keeper")
reader = User.regular.create!(name: "George")

book = Book.create!(title: "Polished Ruby", author: "Jeremy Evans", isbn: "9781801072724")
book_2 = Book.create!(title: "Programming Ruby 3.2", author: "Noel Rappin", isbn: "9781680509823")

class BooksController < ApplicationController
  before_action :require_access, only: [:new, :create, :edit, :update, :destroy]

  def new
    @book = Book.new
  end

  def show
    @book = Book.find(params[:id])
  end

  private

  def require_access
    return unless current_user&.permission?(:manage_books)
    redirect_to books_path, alert: "No access"
  end
end

response = get "/books/new", cookies: {user_id: reader.id}
puts [response.status, response.flash]

response = get "/books/new", cookies: {user_id: librarian.id}
puts [response.status, response.flash]
