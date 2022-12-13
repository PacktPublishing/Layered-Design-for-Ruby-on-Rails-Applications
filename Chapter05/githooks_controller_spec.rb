require_relative "rails_helper"

# Tests for the fat controller
RSpec.describe GithooksController, type: :request do
  let(:event) { ISSUE_PAYLOAD }
  let!(:user) { User.create!(name: "Vova", gh_id: "palkan") }

  subject { post "/callbacks/github", params: event }

  context "when event is issue" do
    it "creates an issue for user", :aggregate_failures do
      expect { subject }.to change(user.issues, :count).by(1)
      expect(response.status).to eq(200)
    end
  end

  context "when event is pull_request" do
    let(:event) { PR_PAYLOAD }

    it "creates an issue for user", :aggregate_failures do
      expect { subject }.to change(user.pull_requests, :count).by(1)
      expect(response.status).to eq(200)
    end
  end

  context "when user is not found" do
    before { user.destroy }

    specify do
      subject
      expect(response.status).to eq(200)
    end
  end

  context "when payload is not JSON" do
    let(:event) { "some_event" }

    it "responds with 422" do
      subject
      expect(response.status).to eq(422)
    end
  end

  context "when signature is missing"
  context "when signature is invalid"
end
