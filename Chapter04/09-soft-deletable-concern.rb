require_relative "./prelude"

module SoftDeletable
  extend ActiveSupport::Concern
  include Discard::Model

  included do
    self.discard_column = :deleted_at
    belongs_to :deleted_by, class_name: "User",
      optional: true
  end

  def discard(by: Current.user)
    self.deleted_by = by
    super()
  end
end

class Post < ApplicationRecord
  include SoftDeletable
end

user = User.create!(name: "Deleter")
post = Post.create!(title: "Delete me!", content: "TBD")

post.discard(by: user)

post.discarded?

post.deleted_by.name
