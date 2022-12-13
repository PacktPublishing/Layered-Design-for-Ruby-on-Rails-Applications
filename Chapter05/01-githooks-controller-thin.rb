require_relative "./prelude"

# Create new model to represent GitHub events
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
    :user_id, :action, :title, :body, :branch)
end

# Add a method to the model implementing webhooks processing logic
class User < ApplicationRecord
  def handle_github_event(event)
    case event
    in GitHubEvent::Issue[action: "opened", title:, body:]
      issues.create!(title:, body:)
    in GitHubEvent::PR[
      action: "opened", title:, body:, branch:
    ]
      pull_requests.create!(title:, body:, branch:)
    end
  end
end

class GithooksController < ApplicationController
  def create
    verify_signature!

    event = GitHubEvent.parse(request.raw_post)
    return head :unprocessable_entity if event.nil?

    user = User.find_by(gh_id: event.user_id)
    user&.handle_github_event(event)

    head :ok
  end

  def verify_signature!
    # Let’s skip the payload signature verification
   # code, since it’s irrelevant to our refactoring
  end
end

# Tests for the thin controller stay the same
require_relative "githooks_controller_spec"
RSpec::Core::Runner.run([])
