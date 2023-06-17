require_relative "./prelude"
using ChapterHelpers

# Test error reporting subscriber
class ErrorSubscriber
  def self.report(error, handled:, severity:, context:, **_other)
    $stdout.puts "[ERROR REPORTED] #{error.class}: #{error.message}\n" \
      "  Context: #{context.inspect}\n" \
      "  Callsite: #{error.backtrace.take(1).first}"
  end
end

Rails.application.executor.error_reporter.subscribe(ErrorSubscriber)

class GitStarsFetcher
  URL_TEMPLATE = "https://api.github.com/repos/%s/%s"

  private attr_reader :logger

  def initialize
    @logger = Rails.logger
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
    Rails.error.report(error, handled: true)
    logger.error "Failed to fetch stars: #{error.message}"
  end
end

Rails.error.set_context(user_id: "2023")

GitStarsFetcher.new.stars_for("rspec", "rspec-core")
