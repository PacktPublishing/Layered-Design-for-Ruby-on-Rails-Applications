require_relative "./prelude"
using ChapterHelpers

root = File.expand_path("..", __dir__) # :ignore:

example_path = File.join(__dir__, "example.rb")

begin
  # Create a temporary file with the example code
  # and delete it after the run, so RuboCop doesn't complain
  File.write(example_path, <<~RUBY)
    client = LayerizeClient.new
    client.test_mode = Rails.env.local?
  RUBY

  system "#{root}/bin/rubocop --only Lint/RailsEnv #{example_path}"
ensure
  File.delete(example_path)
end
