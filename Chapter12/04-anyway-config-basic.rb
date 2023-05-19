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

config = LayerizeConfig.new
pp config

begin
  LayerizeConfig.new(api_key: nil)
rescue => e
  puts "#{e.class}: #{e.message}"
end

p LayerizeConfig.api_key

class LayerizeClient
  def initialize(config: LayerizeConfig)
    @api_key = config.api_key
    @model = config.model
    @callback_url = config.callback_url
  end
end

# Extend with pretty printing capabilities
class LayerizeClient # :ignore:
  def inspect = "<#{self.class} api_key=#{@api_key} model=#{@model} callback=#{@callback_url}>"
end

puts LayerizeClient.new.inspect

config = LayerizeConfig.new(api_key: "another-key")
puts LayerizeClient.new(config:).inspect
