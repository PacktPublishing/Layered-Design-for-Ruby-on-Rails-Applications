require_relative "rails_helper"

RSpec.describe GithooksController, type: :request do
  let(:raw_event) { '{"event":"test"}' }
  let(:event) { GitHubEvent::Issue.new(user_id: "palkan", action: "opened", title: "Issue", body: "Test") }
  let!(:user) { User.create!(name: "Vova", gh_id: "palkan") }

  before do
    allow(GitHubEvent).to receive(:parse).and_return(event)
    # Call original to make sure the happy path is fully covered with tests
    allow(HandleGithubEventService).to receive(:call).and_call_original
  end

  subject { post "/callbacks/github", params: raw_event }

  it "creates an issue for user via HandleGithubEventService", :aggregate_failures do
    expect { subject }.to change(user.issues, :count).by(1)
    expect(response.status).to eq(200)
    expect(GitHubEvent).to have_received(:parse).with(raw_event)
    expect(HandleGithubEventService).to have_received(:call).with(event)
  end

  context "when service cannot process the event" do
    before { allow(GitHubEvent).to receive(:parse).and_return(nil) }

    it "returns 422" do
      subject
      expect(response.status).to eq(422)
    end
  end

  context "when signature is missing"
  context "when signature is invalid"
end
