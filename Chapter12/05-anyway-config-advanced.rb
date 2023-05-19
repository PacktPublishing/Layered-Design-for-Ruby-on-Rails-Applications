require_relative "./prelude"
using ChapterHelpers

class ApplicationConfig < Anyway::Config
  class << self
    delegate_missing_to :instance

    def instance
      @instance ||= new
    end
  end
end

class LayerizeConfig < ApplicationConfig
  attr_config :api_key, :callback_url,
    model: "CakeGPT 1.0", enabled: true

  required :api_key
end

class LayerizeConfig < ApplicationConfig
  attr_config :api_key, :callback_url, :enabled,
    model: "CakeGPT 1.0"

  required :api_key

  coerce_types enabled: :boolean

  on_load :validate_model

  def model_version = model.match(/(\d+\.\d+)/)[1]

  private

  def validate_model
    return if model&.match?(/^CakeGPT \d+\.\d+$/)
    raise ArgumentError, "Unknown model: #{model}"
  end
end

LayerizeConfig.new(model: "CakeGPT 1.5").model_version

begin
  LayerizeConfig.new(model: "CandyLLM 1.0")
rescue => e
  puts "#{e.class}: #{e.message}"
end

ENV["LAYERIZE_ENABLED"] = "0"
LayerizeConfig.new.enabled?
