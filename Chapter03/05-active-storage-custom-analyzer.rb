require_relative "./prelude"

require "id3tag"

# Custom audio analyzer adding track title and artist from ID3 MP3 tags.
class CustomAudioAnalyzer < ActiveStorage::Analyzer::AudioAnalyzer
  def metadata
    super.merge(id3_data)
  end

  private def id3_data
    tag =
      download_blob_to_tempfile do |file|
        ID3Tag.read(File.open(file.path))
      end

    {title: tag.title, artist: tag.artist}
  end
end

# Register the analyzer.
# NOTE: You should do this in the configuration:
#
#   config.active_storage.analyzers.unshift CustomAudioAnalyzer
ActiveStorage.analyzers.unshift CustomAudioAnalyzer

# Declare a model having audio attachments
class Post < ApplicationRecord
  has_one_attached :audio
end

track = File.open(File.join(__dir__, "assets/skit.mp3"))

post = Post.create!(title: "GGM")

post.audio.attach(io: track, filename: "skit.mp3")

post.audio.analyze
post.audio.analyzed?

puts post.audio.metadata.slice(:artist, :title)
