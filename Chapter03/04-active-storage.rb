require_relative "./prelude"

class Post < ApplicationRecord
  has_one_attached :image
end

# Now you can create a post with an image
image = File.open(File.join(__dir__, "assets/example.png"))

post = Post.create!(title: "Test")

post.image.attach(io: image, filename: "example.png")

binding.render <<~ERB
  <%= image_tag post.image.variant(resize: "400x300") %>
ERB
