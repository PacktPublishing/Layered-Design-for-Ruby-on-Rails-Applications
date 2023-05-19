require_relative "./prelude"
using ChapterHelpers

class LayerizeClient
  def initialize
    @api_key = credentials&.api_key || yml_config[:api_key]
    @model = yml_config[:model]
    @callback_url = ENV["LAYERIZE_CALLBACK_URL"] ||
      credentials&.callback_url ||
      yml_config[:callback_url]
  end

  private

  def credentials = Rails.application.credentials.layerize

  def yml_config =
    @yml_config ||= Rails.application.config_for(:layerize)
end

# Extend with pretty printing capabilities
class LayerizeClient # :ignore:
  def inspect = "<#{self.class} api_key=#{@api_key} model=#{@model} callback=#{@callback_url}>"
end

puts LayerizeClient.new.inspect
