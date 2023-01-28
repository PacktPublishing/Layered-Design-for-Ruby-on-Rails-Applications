require_relative "./prelude"

class Post < ApplicationRecord
  scope :tagged, ->(tag) {
    where("EXISTS (SELECT 1 FROM json_each(tags) WHERE value = ?)", tag)
  }
end

post = Post.create(title: "Active Record vs. Data Mapper", tags: %w[rails orm])

post.update!(draft: false)

Post.all

Post.tagged("rails")

class PostsRepository
  def all = Post.all.to_a

  def find(id) = Post.find_by(id:)

  def add(attrs) = Post.create!(attrs)

  def publish(post) = post.update!(draft: false)

  def search(tag: nil)
    Post.where("EXISTS (SELECT 1 FROM json_each(tags) WHERE value = ?)", tag)
  end
end

repo = PostsRepository.new

post = repo.add(title: "Repositories on Rails", tags: %w[orm data_mapper])

repo.publish(post)

repo.all

repo.search(tag: "orm")

class ApplicationRepository
  class << self
    attr_writer :model_name

    def model_name
      @model_name ||= name.sub(/Repository$/, "").singularize
    end

    def model
      model_name.safe_constantize
    end
  end

  delegate :model, to: :class

  def all = model.all.to_a

  def find(id) = model.find_by(id:)

  def add(attrs) = model.create!(attrs)
end

# Make sure the constant is fresh
Object.send(:remove_const, :PostsRepository) # :ignore:all

class PostsRepository < ApplicationRepository
  def publish(post) = post.update!(draft: false)

  def search(tag: nil)
    model.where("EXISTS (SELECT 1 FROM json_each(tags) WHERE value = ?)", tag)
  end
end

repo = PostsRepository.new

post = repo.add(title: "Repositories on Rails", tags: %w[orm data_mapper])

repo.publish(post)

repo.all

repo.search(tag: "orm")
