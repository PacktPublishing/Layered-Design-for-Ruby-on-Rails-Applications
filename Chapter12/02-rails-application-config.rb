require_relative "./prelude"
using ChapterHelpers

Rails.application.config.layerize = Rails.application.config_for(:layerize)

class LayerizeClient
  def initialize
    @api_key = config[:api_key]
    @model = config[:model]
    @callback_url = config[:callback_url]
  end

  private

  def config = Rails.application.config.layerize
end

# Extend with pretty printing capabilities
class LayerizeClient # :ignore:
  def inspect = "<#{self.class} api_key=#{@api_key} model=#{@model} callback=#{@callback_url}>"
end

puts LayerizeClient.new.inspect
