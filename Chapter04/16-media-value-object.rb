require_relative "./prelude"

SVG_TYPES = %w[
  image/svg
  image/svg+xml
].freeze

FONT_TYPES = %w[
  font/otf
  font/ttf
  font/woff
  font/woff2
].freeze

MediaType = Data.define(:content_type) do
  include Comparable

  def <=>(other) = content_type <=> other.content_type

  def video? = content_type.start_with?("video")

  def svg? = SVG_TYPES.include?(content_type)

  def font? = FONT_TYPES.include?(content_type)
  # … more <type>? methods
end

module WithMedia
  extend ActiveSupport::Concern

  included do
    has_one_attached :media
  end

  def media_type
    return unless media&.content_type

    MediaType.new(media.content_type)
  end
end

class Post < ApplicationRecord
  include WithMedia
end

post = Post.create!(title: "Media assets", content: "Some svg")
post.media.attach(io: File.open(File.join(__dir__, "assets/logo.svg")), filename: "logo.svg")

post.media_type.svg?

post.media_type.font?
