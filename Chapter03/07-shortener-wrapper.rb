require_relative "./prelude"

# Phase 0: Configure an API client globally and use the third-party API everywhere
Rails.application.config.bitly_client = Bitly::API::Client.new(
  token: Rails.credentials.bitly_api_token
)

url = "https://rubyonrails.org"

short_url = Rails.application.config
                 .bitly_client.shorten(long_url: url).link


# Phase 1: Introduce a Shortener domain concept
# and create a simple wrapper over Bitly API Client
class Shortener
  class << self
    delegate :shorten, to: :instance
    def instance() = @instance ||= new
  end

  def initialize(token: Rails.credentials.bitly_api_token)
    @client = Bitly::API::Client.new(token:)
  end

  def shorten(long_url)
    @client.shorten(long_url:).link
  end
end

Shortener.shorten("https://rubyonrails.org")

def some_method_using_shortener
  "Short url for: #{Shortener.shorten("https://example.com")}"
end

# With a wrapper object, integration tests do not need to
# know about the particular implementation (API client)
class ShortenerTest < ActiveSupport::TestCase
  test "with shortener" do
    Shortener.stub :shorten, "http://exml.test" do
      result = some_method_using_shortener
      assert result.include?("http://exml.test")
    end
  end
end

Minitest.run
