require_relative "./prelude"
using ChapterHelpers

class Project < ApplicationRecord
  scope :future, -> { where(started_at: Time.current...) }
end

class ApplicationFilter < Rubanok::Processor
  class << self
    alias filter call
  end
end

class ProjectsFilter < ApplicationFilter
  TYPES = %w[draft published].freeze
  SORT_FIELDS = %w[id name started_at].freeze
  SORT_ORDERS = %w[asc desc].freeze

  map :type_filter do |type_filter:|
    next raw.none unless TYPES.include?(type_filter)

    raw.where(status: type_filter)
  end

  match :time_filter do
    having "future" do
      raw.future
    end
  end

  map :sort_by, :sort_order, activate_always: true do |sort_by: "started_at", sort_order: "desc"|
    next raw unless SORT_FIELDS.include?(sort_by) &&
      SORT_ORDERS.include?(sort_order)

    raw.order(sort_by => sort_order)
  end

  map :q do |q:|
    raw.where(Project[:name].matches("%#{q}%"))
  end
end

class ProjectsController < ApplicationController
  def index
    projects = ProjectsFilter.filter(Project.all, params)
    render json: projects
  end
end

require_relative "rails_helper"

RSpec.describe ProjectsController, type: :request do
  before do
    allow(ProjectsFilter)
      .to receive(:filter).and_call_original
  end

  it "uses ProjectsFilter" do
    get "/projects.json"
    expect(response.status).to eq(200)
    expect(ProjectsFilter).to have_received(:filter)
      .with(Project.all,
        an_instance_of(ActionController::Parameters))
  end
end

require_relative "projects_controller_spec"
RSpec::Core::Runner.run([])
