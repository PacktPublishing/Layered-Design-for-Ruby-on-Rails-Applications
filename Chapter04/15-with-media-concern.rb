require_relative "./prelude"

module WithMedia
  extend ActiveSupport::Concern

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

  included do
    has_one_attached :media

    delegate :video?, :audio?, to: :media
  end

  def font? = FONT_TYPES.include?(media.content_type)

  def svg? = SVG_TYPES.include?(media.content_type)
  # … more <type>? methods
end

class Post < ApplicationRecord
  include WithMedia
end

post = Post.create!(title: "Media assets", content: "Some svg")
post.media.attach(io: File.open(File.join(__dir__, "assets/logo.svg")), filename: "logo.svg")

post.svg?

post.font?
