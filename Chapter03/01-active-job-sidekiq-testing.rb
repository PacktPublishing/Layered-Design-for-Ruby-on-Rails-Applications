require_relative "./prelude"

class TrackAnalyticsJob < ApplicationJob
  queue_as :low_priority

  def perform(user, event)
    Analytics::Tracker.push_event(
      {user: {name: user.name, id: user.id}, event:}
    )
  end
end

class TrackAnalyticsWorker
  include Sidekiq::Worker

  def perform(user_id, event)
    user = User.find(user_id)

    Analytics::Tracker.push_event(
      {user: {name: user.name, id: user.id}, event:}
    )
  end
end

user = User.find(1)

TrackAnalyticsWorker.perform_async(user.id, "signed_in")

class User
  def track_event(event)
    TrackAnalyticsJob.perform_later(self, event)
  end
end

class UserTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "analytics job scheduling" do
    @user = User.create!(name: "Vova")

    assert_enqueued_with(
      job: TrackAnalyticsJob,
      args: [@user, "signed_in"]
    ) do
      @user.track_event("signed_in")
    end
  end

  test "analytics active job" do
    event_checker = lambda do |event|
      assert(event => {user: {name: "Vova"}, event: "test"})
    end

    user = User.new(name: "Vova")

    Analytics::Tracker.stub :push_event, event_checker do
      TrackAnalyticsJob.perform_now(user, "test")
    end
  end

  test "analytics Sidekiq worker" do
    event_checker = lambda do |event|
      assert(event => {user: {name: "Vova"}, event: "test"})
    end

    user = User.create!(name: "Vova") # !!!

    Analytics::Tracker.stub :push_event, event_checker do
      TrackAnalyticsWorker.new.perform(user.id, "test")
    end
  end
end

Minitest.run
