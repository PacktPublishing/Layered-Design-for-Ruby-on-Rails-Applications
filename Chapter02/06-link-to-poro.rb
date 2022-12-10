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
  attr_reader :id

  def initialize(id) = @id = id
  def persisted? = true
  def to_param = id.to_s

  def model_name
    ActiveModel::Name.new(self.class)
  end
end

puts link_to("Object", Book.new(2023))
