require_relative "./prelude"
using ChapterHelpers

get "/", headers: {"X-Request-ID" => "req-1", "X-User-ID" => "42"}

class GitStarsFetcher
  URL_TEMPLATE = "https://api.github.com/repos/%s/%s"

  private attr_reader :logger

  def initialize
    @logger = Rails.logger.tagged("⭐️")
  end

  def stars_for(org, repo)
    logger.debug "Fetching stars for: #{org}/#{repo}"

    uri = URI(URL_TEMPLATE % [org, repo])

    response = Net::HTTP.get_response(uri)

    if response.code != "200"
      logger.error "Failed to fetch stars: HTTP #{response.code}"
      return
    end

    stars = JSON.parse(response.body).fetch("stargazers_count")
    logger.debug "Stars fetched successfully: #{stars}"
    stars
  rescue SocketError, Net::HTTPError, JSON::ParserError, KeyError => error
    logger.error "Failed to fetch stars: #{error.message}"
  end
end

GitStarsFetcher.new.stars_for("test-prof", "test-prof")
