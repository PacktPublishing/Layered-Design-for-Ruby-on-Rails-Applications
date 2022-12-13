require_relative "./prelude"

class GithooksController < ApplicationController
  rescue_from JSON::ParserError do
    head :unprocessable_entity
  end

  def create
    verify_signature!

    event = parse_event request.raw_post

    case event
    in type: "issue", action: "opened",
       issue: {user: {login:}, title:, body:}
      track_issue(login, title, body)
    in type: "pull_request", action: "opened",
       pull_request: {
         user: {login:}, base: {label:}, title:, body:
       }
      track_pr(login, title, body, label)
    end

    head :ok
  end

  def verify_signature!
    # Let’s skip the payload signature verification
   # code, since it’s irrelevant to our refactoring
  end

  def parse_event(payload)
    JSON.parse(payload, symbolize_names: true)
  end

  def track_issue(login, title, body)
    User.find_by(gh_id: login)
        &.issues.create!(title:, body:)
  end

  def track_pr(login, title, body, branch)
    User.find_by(gh_id: login)
        &.pull_requests.create!(title:, body:, branch:)
  end
end

require_relative "githooks_controller_spec"
RSpec::Core::Runner.run([])
