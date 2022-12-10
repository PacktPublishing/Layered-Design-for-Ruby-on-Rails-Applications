require_relative "./prelude"

class Book < ApplicationRecord
end

# Inserting data into the database
Book.create!(title: "The Ruby on Rails book")

# Retrieving data via model finder methods
book = Book.find_by(title: "The Ruby on Rails book")

# Modifying data
book.update!(category: "programming")

# Deleting data
book.destroy!
