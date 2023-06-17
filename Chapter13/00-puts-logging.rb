require_relative "./prelude"
using ChapterHelpers

class GitStarsFetcher
  URL_TEMPLATE = "https://api.github.com/repos/%s/%s"

  def stars_for(org, repo)
    puts "Fetching stars for: #{org}/#{repo}"

    uri = URI(URL_TEMPLATE % [org, repo])

    response = Net::HTTP.get_response(uri)

    if response.code != "200"
      puts "Failed to fetch stars: HTTP #{response.code}"
      return
    end

    stars = JSON.parse(response.body).fetch("stargazers_count")
    puts "Stars fetched successfully: #{stars}"
    stars
  rescue SocketError, Net::HTTPError, JSON::ParserError, KeyError => error
    puts "Failed to fetch stars: #{error.message}"
  end
end

GitStarsFetcher.new.stars_for("rails", "rails")

GitStarsFetcher.new.stars_for("rails", "rails-x")
