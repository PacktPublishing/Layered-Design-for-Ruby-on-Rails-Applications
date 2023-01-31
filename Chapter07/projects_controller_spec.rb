require_relative "rails_helper"

RSpec.describe ProjectsController, type: :request do
  before do
    # Make sure the database is clean
    Project.delete_all
    Project.insert_all([
      {
        name: "Layering Rails book",
        started_at: Time.zone.parse("2022-07-01 9:00:00"),
        status: "draft"
      },
      {
        name: "Real-time Rails book",
        started_at: 1.year.since,
        status: "draft"
      },
      {
        name: "AnyCable",
        started_at: Time.zone.parse("2016-07-15 11:04:00"),
        status: "published"
      }
    ])
  end

  let(:params) { {} }

  subject(:data) do
    get("/projects", params:)
    JSON.parse(response.body, symbolize_names: true)
  end

  specify do
    expect(data.size).to eq 3
    expect(data.map { _1[:name] }).to eq(%w[
      Real-time\ Rails\ book
      Layering\ Rails\ book
      AnyCable
    ])
  end

  specify "?sort_by=name&sort_order=asc" do
    params[:sort_by] = "name"
    params[:sort_order] = "asc"

    expect(data.size).to eq 3
    expect(data.map { _1[:name] }).to eq(%w[
      AnyCable
      Layering\ Rails\ book
      Real-time\ Rails\ book
    ])
  end

  specify "?sort_by=id" do
    params[:sort_by] = "id"

    expect(data.size).to eq 3
    expect(data.map { _1[:name] }).to eq(%w[
      AnyCable
      Real-time\ Rails\ book
      Layering\ Rails\ book
    ])
  end

  specify "?type_filter=published" do
    params[:type_filter] = "published"

    expect(data.size).to eq 1
    expect(data.map { _1[:name] }).to eq(%w[
      AnyCable
    ])
  end

  specify "?type_filter=unknown" do
    params[:type_filter] = "unknown"

    # Rubanok is stricter about unknown values
    if defined?(ProjectsFilter)
      expect(data.size).to eq 0
    else
      expect(data.size).to eq 3
    end
  end

  specify "?time_filter=future" do
    params[:time_filter] = "future"

    expect(data.size).to eq 1
    expect(data.map { _1[:name] }).to eq(%w[
      Real-time\ Rails\ book
    ])
  end

  specify "?q=Rails" do
    params[:q] = "Rails"

    expect(data.size).to eq 2
    expect(data.map { _1[:name] }).to eq(%w[
      Real-time\ Rails\ book
      Layering\ Rails\ book
    ])
  end
end
