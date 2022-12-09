# frozen_string_literal: true

require_relative "../lib/helpers"

using ChapterHelpers

# Add gems
gems do
  gem "trace_location", github: "palkan/trace_location"
end

require_relative "../lib/boot"

# Configure output folder for trace_location
require "trace_location"
TraceLocation.configure do |config|
  config.dest_dir = File.join(__dir__, "../log")
end
