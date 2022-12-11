require_relative "./prelude"

class DummyVideoPreviewer < ActiveStorage::Previewer
  def self.accept?(...) = true

  def preview(**options)
    output = File.open(File.join(__dir__, "assets", "example.png"))
    yield io: output, filename: "#{blob.filename.base}.png", content_type: "image/png", metadata: { "dummy" => true }, **options
  end
end

# Configure Active Storage previewers.
# NOTE: you should do this in configuration files (e.g., config/environments/test.rb)
#
#   config.active_storage.previewers = [DummyVideoPreviewer]
ActiveStorage.previewers = [DummyVideoPreviewer]

class Post < ApplicationRecord
  has_one_attached :video
end

video = File.open(File.join(__dir__, "../assets/demo.gif"))
post = Post.create!(title: "Demo")
post.video.attach(io: video, filename: "demo.gif")

# Generate the preview source file (not transformed)
preview = post.video.preview(resize_to_limit: [100, 100]).processed
puts preview.image.metadata
