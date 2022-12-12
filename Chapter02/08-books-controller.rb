require_relative "./prelude"
using ChapterHelpers

class Category
  include ActiveModel::API
  include ActiveModel::Attributes

  attribute :category

  ALL = %w[ruby other].freeze

  def self.all = ALL.map { new(category: _1) }

  alias_method :id, :category

  def persisted? = true
  def books = Book.where(category:)
end

class BooksController < ApplicationController
  def index
    @categories = Category.all
  end
end

response = get "/books"

puts response.body
