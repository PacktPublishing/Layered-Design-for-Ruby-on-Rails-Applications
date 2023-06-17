require_relative "./prelude"
using ChapterHelpers

class GitStarsFetcher
  URL_TEMPLATE = "https://api.github.com/repos/%s/%s"

  def stars_for(org, repo)
    Rails.logger.debug "Fetching stars for: #{org}/#{repo}"

    uri = URI(URL_TEMPLATE % [org, repo])

    response = Net::HTTP.get_response(uri)

    if response.code != "200"
      Rails.logger.error "Failed to fetch stars: HTTP #{response.code}"
      return
    end

    stars = JSON.parse(response.body).fetch("stargazers_count")
    Rails.logger.debug "Stars fetched successfully: #{stars}"
    stars
  rescue SocketError, Net::HTTPError, JSON::ParserError, KeyError => error
    Rails.logger.error "Failed to fetch stars: #{error.message}"
  end
end

GitStarsFetcher.new.stars_for("anycable", "anycable")

GitStarsFetcher.new.stars_for("anycable", "anycable-mqtt")
