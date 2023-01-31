require_relative "./prelude"
using ChapterHelpers

class ApplicationRecord < ActiveRecord::Base
  def self.filter_by(params, with: nil)
    filter_class = with || "#{name.pluralize}Filter".constantize
    filter_class.filter(self, params)
  end
end

class ApplicationFilter < Rubanok::Processor
  class << self
    alias filter call
  end
end

class ProjectsFilter < ApplicationFilter
  # ...

  map :q do |q:|
    raw.where(Project[:name].matches("%#{q}%"))
  end
end

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

puts Project.filter_by({q: "Any"}).pluck(:name)

puts Project.where(started_at: ...Time.current).filter_by({q: "Rails"}).pluck(:name)
