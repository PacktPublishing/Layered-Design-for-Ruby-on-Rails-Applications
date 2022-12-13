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

# Now we move service object out of the user namespace and
# leave only the event parameter
class HandleGithubEventService < ApplicationService
  param :event

  def call
    user = User.find_by(gh_id: event.user_id)
    return false unless user

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

    event = GitHubEvent.parse(request.raw_post)
    return head :unprocessable_entity if event.nil?

    HandleGithubEventService.call(event)
    head :ok
  end

  def verify_signature!
    # Let’s skip the payload signature verification
    # code, since it’s irrelevant to our refactoring
  end
end

# Now we can update our tests too—no need to worry about users,
# no need to test all the event types, we can only verify that the right
# service is called with the expected parameters
require_relative "githooks_controller_service_spec"
RSpec::Core::Runner.run([])
