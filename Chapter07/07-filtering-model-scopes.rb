require_relative "./prelude"
using ChapterHelpers

class Project < ApplicationRecord
  scope :filter_by_type, -> {
    where(status: _1) if _1.in?(%w[published draft])
  }
  scope :filter_by_time, -> {
    where(started_at: Time.current...) if _1 == "future"
  }
  scope :searched, -> {
    where(arel_table[:name].matches("%#{_1}%")) if
      _1.present?
  }
  scope :sorted, (lambda do |col, ord|
    col = :started_at unless
      col.in?(%w[id name started_at])
    ord = :desc unless ord.in?(%w[asc desc])

    order(col => ord)
  end)
end

class ProjectsController < ApplicationController
  def index
    projects = Project.all
      .filter_by_type(params[:type_filter])
      .filter_by_time(params[:time_filter])
      .searched(params[:q])
      .sorted(params[:sort_by], params[:sort_order])

    render json: projects
  end
end

require_relative "projects_controller_spec"
RSpec::Core::Runner.run([])
