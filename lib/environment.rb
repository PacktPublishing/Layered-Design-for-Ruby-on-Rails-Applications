# frozen_string_literal: true

require_relative "./helpers"

# First, we setup the dependencies.
# We use inline Gemfile for that and make it possible to extend it from examples
# by using the GemsInline helper module
require 'bundler/inline'

retried = false
begin
  gemfile(retried, quiet: true) do
    source 'https://rubygems.org'

    gem 'rails', '~> 7.0.0'
    # We use in-memory sqlite as our database
    gem 'sqlite3', '~> 1.5.4'
    # Debugger could be used to dig deeper into some code examples
    gem 'debug', '~> 1.7.0'
    # Highlight code in the terminal
    gem 'rouge', '~> 4.0.0'

    ChapterHelpers.extend!(:gemfile, self)
  end
rescue Gem::MissingSpecError
  raise if retried

  retried = true
  retry
end

# Then, load the Rails application
require_relative "./application"
