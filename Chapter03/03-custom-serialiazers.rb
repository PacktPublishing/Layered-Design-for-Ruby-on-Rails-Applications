require_relative "./prelude"

class Category < Struct.new(:name, keyword_init: true)
end

class CategoryJob < ApplicationJob
  def perform(category)
    puts "Category job: #{category.name}"
  end
end

category = Category.new(name: :rails)

# Without custom serializer, enqueing fails
begin
  CategoryJob.perform_later(category)
rescue ActiveJob::SerializationError => err
  puts "#{err.class}: #{err.message}"
end

# Custom Active Job serializer
module ActiveJob::Serializers
  class CategorySerializer < ObjectSerializer
    def serialize(cat) = super("name" => cat.name)

    def deserialize(h) = Category.new(name: h["name"])
    private def klass = Category
  end
end

ActiveJob::Serializers.add_serializers ActiveJob::Serializers::CategorySerializer

CategoryJob.perform_later(category)
