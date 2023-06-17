require_relative "./prelude"
using ChapterHelpers

# Warm-up schema cache
User.first

ActiveSupport::Notifications.subscribe("sql.active_record") do |event|
  puts "SQL: #{event.payload[:sql]}"
end

User.first

# Adding instrumentation to GitStarsFetcher
class GitStarsFetcher
  URL_TEMPLATE = "https://api.github.com/repos/%s/%s"

  def stars_for(org, repo)
    uri = URI(URL_TEMPLATE % [org, repo])

    payload = {repo: "#{org}/#{repo}"}
    ActiveSupport::Notifications.instrument("fetch_stars.gh", payload) do
      response = Net::HTTP.get_response(uri)
      stars = JSON.parse(response.body).fetch("stargazers_count")
      payload[:stars] = stars
    end
  rescue SocketError, Net::HTTPError, JSON::ParserError, KeyError => error
    Rails.error.report(error, handled: true)
  end
end

subscriber = ActiveSupport::Notifications.subscribe("fetch_stars.gh") do
  puts("repo=#{_1.payload[:repo]} stars=#{_1.payload[:stars]} duration=#{_1.duration}")
end

GitStarsFetcher.new.stars_for("rails", "rails")

ActiveSupport::Notifications.unsubscribe(subscriber) # :ignore:

# Creating a log subscriber
class GHLogSubscriber < ActiveSupport::LogSubscriber
  def fetch_stars(event)
    repo = event.payload[:repo]
    ex = event.payload[:exception_object]
    if ex
      error do
        "Failed to fetch stars for #{repo}: #{ex.message}"
      end
    else
      debug do
        "Fetched stars for #{repo}: #{event.payload[:stars]} (#{event.duration.round(2)}ms)"
      end
    end
  end
end

GHLogSubscriber.attach_to :gh

GitStarsFetcher.new.stars_for("rails", "rails")

# Configuring metrics with Yabeda
Yabeda.configure do
  counter :gh_stars_call_total
  counter :gh_stars_call_failed_total
  histogram :gh_stars_call_duration, unit: :millisecond, buckets: [10, 50, 100, 200, 500]
end

# Define a custom Yabeda collector for testing purposes
require "yabeda/base_adapter"

module Yabeda
  module Stdout
    class Adapter < BaseAdapter
      def register_counter!(_metric)
      end

      def perform_counter_increment!(counter, tags, increment)
        $stdout.puts "[METRICS] #{counter.name}#{build_tags(tags)} #{increment}"
      end

      def register_gauge!(_metric)
      end

      def perform_gauge_set!(metric, tags, value)
        $stdout.puts "[METRICS] #{metric.name}#{build_tags(tags)} #{value}"
      end

      def register_histogram!(_metric)
      end

      def perform_histogram_measure!(metric, tags, value)
        $stdout.puts "[METRICS] #{metric.name}#{build_tags(tags)} #{value}"
      end

      private

      def build_tags(tags)
        return if tags.nil? || tags.empty?

        tags.map { |k, v| "#{k}=#{v}" }.join(",").then { "{#{_1}}" }
      end

      Yabeda.register_adapter(:stdout, new)
    end
  end
end

# Adding Yabeda subscriber
ActiveSupport::Notifications.subscribe("fetch_stars.gh") do
  Yabeda.gh_stars_call_total.increment({})
  if _1.payload[:exception]
    Yabeda.gh_stars_call_failed_total.increment({})
  else
    Yabeda.gh_stars_call_duration.measure({}, _1.duration)
  end
end

GitStarsFetcher.new.stars_for("rails", "rails")
