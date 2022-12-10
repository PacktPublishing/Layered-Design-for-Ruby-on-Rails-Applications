require_relative "./prelude"

# #content_tag stub
def content_tag(tag, text, attrs = {})
  "<#{tag} #{attrs.map { |k, v| "#{k}=\"#{v}\""}.join(" ")}>#{text}</#{tag}>"
end

def link_to(name, record)
  parts = [""]

  if record.persisted?
    parts << record.model_name.singular_route_key
    parts << record.to_param
  else
    parts << record.model_name.route_key
  end

  content_tag("a", name, {href: parts.join("/")})
end

class Book
  include ActiveModel::API
  include ActiveModel::Attributes

  attribute :id

  def persisted?() = true
end

puts link_to("Object", Book.new(id: 2023))

class BookTest < ActiveSupport::TestCase
  include ActiveModel::Lint::Tests

  def setup() = @model = Book.new
end

Minitest.run
