# frozen_string_literal: true

require_relative "./helpers"

# First, we setup the dependencies.
# We use inline Gemfile for that and make it possible to extend it from examples
# by using the GemsInline helper module
require 'bundler/inline'

gemfile(true, quiet: true) do
  source 'https://rubygems.org'

  gem 'rails', '~> 7'
  # We use in-memory sqlite as our database
  gem 'sqlite3'
  # Debugger could be used to dig deeper into some code examples
  gem 'debug'

  ChapterHelpers.extend!(:gemfile, self)
end

# Then, load the Rails application
require_relative "./application"
