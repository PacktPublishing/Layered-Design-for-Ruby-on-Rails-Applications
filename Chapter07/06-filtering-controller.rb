require_relative "./prelude"
using ChapterHelpers

class ProjectsController < ApplicationController
  def index
    projects = Project.all.order(sort_params)

    if params[:type_filter].in?(%w[published draft])
      projects.where!(
        status: params[:type_filter]
      )
    end

    if params[:time_filter] == "future"
      projects.where!(started_at: Time.current...)
    end

    if params[:q].present?
      projects.where!(Project[:name].matches("%#{params[:q]}%"))
    end

    render json: projects
  end

  def sort_params
    col, ord = params.values_at(:sort_by, :sort_order)

    col = :started_at unless col.in?(%w[id name started_at])
    ord = :desc unless ord.in?(%w[asc desc])

    {col => ord}
  end
end

require_relative "projects_controller_spec"
RSpec::Core::Runner.run([])
