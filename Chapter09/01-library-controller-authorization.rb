require_relative "./prelude"
using ChapterHelpers

class User < ApplicationRecord
  enum :role, regular: "regular", admin: "admin",
    librarian: "librarian"
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
    return if current_user&.librarian? ||
      current_user&.admin?

    redirect_to books_path, alert: "No access"
  end
end

response = get "/books/new", cookies: {user_id: reader.id}
puts [response.status, response.flash]

response = get "/books/new", cookies: {user_id: librarian.id}
puts [response.status, response.flash]
