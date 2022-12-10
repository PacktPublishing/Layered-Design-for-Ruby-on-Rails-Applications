require_relative "./prelude"

class Book < Struct.new(:title, :category)
end

# BookRepository is our data mapper implementation
id = BookRepository.insert(title: "Rails and ORM", category: "programming")

book = BookRepository.find(id)

book.title
