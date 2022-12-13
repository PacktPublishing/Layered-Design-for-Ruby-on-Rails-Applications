require_relative "./prelude"

class TrackAnalyticsJob < ApplicationJob
  queue_as :low_priority

  def perform(user, event)
    Analytics::Tracker.push_event(
      {user: {name: user.name, id: user.id}, event:}
    )
  end
end

user = User.find(1)

TrackAnalyticsJob.perform_later(user, "signed_in")

class NoopAdapter
  def enqueue(*) = nil

  def enqueue_at(*) = nil
end

ActiveJob::Base.queue_adapter = NoopAdapter.new

TrackAnalyticsJob.perform_later(user, "signed_out")
