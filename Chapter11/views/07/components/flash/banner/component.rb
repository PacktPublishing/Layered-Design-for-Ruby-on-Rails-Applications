# frozen_string_literal: true

class Flash::Banner::Component < ApplicationViewComponent
  param :text
  option :level, default: proc { :info }

  def render? = text.presence?

  def level_class
    case level
    when :info then "bg-blue-100 text-blue-800"
    when :error then "bg-red-100 text-red-800"
    end
  end
end
