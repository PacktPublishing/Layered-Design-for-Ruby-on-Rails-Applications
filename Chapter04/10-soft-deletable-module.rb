require_relative "./prelude"

# Pure Ruby module soft-deletable implementation
module SoftDeletable
  def self.included(base)
    base.include Discard::Model
    base.discard_column = :deleted_at
    base.belongs_to :deleted_by, class_name: "User",
                                 optional: true
    base.include InstanceMethods
  end

  module InstanceMethods
    def discard(by: Current.user)
      self.deleted_by = by
      super()
    end
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
