require_relative "./prelude"
using ChapterHelpers

user = User.create!(name: "Vova Dem")

rails_book = Book.create!(title: "The Rails 4 Way")
ruby_book = Book.create!(title: "Polished Ruby programming")
layers_book = Book.create!(title: "Layering Rails")

user.book_reads.create!(book: rails_book, read_at: 7.years.ago, score: 4)
user.book_reads.create!(book: ruby_book, read_at: 42.days.ago, score: 4.5)
user.book_reads.create!(book: Book.create!(title: "The gardener is not the murderer"), read_at: 100.days.ago, score: 3.5)
user.book_reads.create!(book: layers_book, read_at: nil, score: nil)

class BooksController < ApplicationController # :ignore:
  def index
  end
end

class BookPresenter < SimpleDelegator
end

class User::BookPresenter < BookPresenter
  private attr_reader :book_read

  delegate :read?, :read_at, :score, to: :book_read

  def initialize(book, book_read)
    super(book)
    @book_read = book_read
  end

  def progress_icon
    read? ? "fa-circle-check" : "fa-clock"
  end

  def score_class
    case score
    when 0..2 then "text-red-600"
    when 3...4 then "text-yellow-600"
    when 4... then "text-green-600"
    end
  end
end

binding.render <<~ERB
  <%- user.book_reads.preload(:book).each do |book_read| -%>
    <%- book = User::BookPresenter.new(book_read.book, book_read) -%>
    <div id="book-<%= book.id %>">
      <h1>
         <%= book.title %>
         <i class="fa <%= book.progress_icon %>"></i>
       </h1>
       <%- if book.read? %>
         <div>
            <span>Read on <%= l(book.read_at) %></span>
            <span class="<%= book.score_class %>">
              <%= book.score %> / 5
            </span>
         </div>
       <% end %>
    </div>
  <% end %>
ERB
