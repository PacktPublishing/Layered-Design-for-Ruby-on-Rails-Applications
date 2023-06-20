require_relative "./prelude"

class Post < ApplicationRecord
  before_validation :compute_shortname, on: :create
  before_validation :squish_content, if: :content_changed?
  before_save :set_word_count, if: :content_changed?
  validates :short_name, :content, :word_count,
    presence: true

  private

  def compute_shortname
    self.short_name ||= title.parameterize
  end

  def squish_content
    content.squish!
  end

  def set_word_count
    self.word_count = content.split(/\s+/).size
  end
end

post = Post.create!(title: "Layering Rails", content: "A book of callbacks")

puts post.attributes

# Rails 7.1 normalization API example
class NormalizedPost < ApplicationRecord
  self.table_name = "posts"

  normalizes :content, with: -> { _1.squish }
end

post = NormalizedPost.create!(title: "Layering Rails 7.1", content: " A book of\n normalizations  ")

puts post.content
