require_relative "./prelude"

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

request = Rack::MockRequest.env_for('http://localhost:3000/books')
_, _, body = Rails.application.call(request)

puts body
