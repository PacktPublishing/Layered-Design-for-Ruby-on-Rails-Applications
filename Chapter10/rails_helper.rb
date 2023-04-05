# frozen_string_literal: true

require "rspec/rails"

require "active_delivery/testing"
require "abstract_notifier/testing"

require "active_delivery/testing/rspec"
require "abstract_notifier/testing/rspec"

AbstractNotifier.delivery_mode = :test

RSpec.configure do |config|
  config.use_transactional_fixtures = true
end
