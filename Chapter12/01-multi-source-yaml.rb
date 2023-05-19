require_relative "./prelude"
using ChapterHelpers

class LayerizeClient
  def initialize
    @api_key = config[:api_key]
    @model = config[:model]
    @callback_url = config[:callback_url]
  end

  private

  def config =
    @config ||= Rails.application.config_for(:layerize)
end

# Extend with pretty printing capabilities
class LayerizeClient # :ignore:
  def inspect = "<#{self.class} api_key=#{@api_key} model=#{@model} callback=#{@callback_url}>"
end

puts LayerizeClient.new.inspect
