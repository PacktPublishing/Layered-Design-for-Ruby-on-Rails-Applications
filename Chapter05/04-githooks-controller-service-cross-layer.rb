require_relative "./prelude"

class GitHubEvent
  def self.parse(raw_event)
    parsed = JSON.parse(raw_event, symbolize_names: true)
    case parsed[:type]
    when "issue"
      Issue.new(
        user_id: parsed.dig(:issue, :user, :login),
        action: parsed[:action],
        **parsed[:issue].slice(:title, :body)
      )
    when "pull_request"
      PR.new(
        user_id: parsed.dig(:pull_request, :user, :login),
        action: parsed[:action],
        branch: parsed.dig(:pull_request, :base, :label),
        **parsed[:pull_request].slice(:title, :body)
      )
    end
  rescue JSON::ParserError
    nil
  end

  Issue = Data.define(:user_id, :action, :title, :body)
  PR = Data.define(
    :user_id, :action, :title, :body, :branch
  )
end

# Base class for service objects implementing Callbable interface
class ApplicationService
  extend Dry::Initializer

  def self.call(...) = new(...).call
end

# Updated service object responsible for processing GitHub webhooks.
# Now it accepts the request object as input. This makes it dependent on the
# presentation layer.
class HandleGithubEventService < ApplicationService
  param :request

  def call
    event = GitHubEvent.parse(request.raw_post)
    return false unless event

    user = User.find_by(gh_id: event.user_id)
    return true unless user

    case event
    in GitHubEvent::Issue[action: "opened", title:, body:]
      user.issues.create!(title:, body:)
    in GitHubEvent::PR[
      action: "opened", title:, body:, branch:
    ]
      user.pull_requests.create!(title:, body:, branch:)
    else
      # ignore unknown events
    end

    true
  end
end

class GithooksController < ApplicationController
  def create
    verify_signature!

    if HandleGithubEventService.call(request)
      head :ok
    else
      head :unprocessable_entity
    end
  end

  def verify_signature!
    # Let’s skip the payload signature verification
    # code, since it’s irrelevant to our refactoring
  end
end

require_relative "githooks_controller_spec"
RSpec::Core::Runner.run([])
