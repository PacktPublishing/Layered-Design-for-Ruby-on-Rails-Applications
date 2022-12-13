# frozen_string_literal: true

# Define base classes for the app.
# Must be declared after application initialization to work correctly
# (for example, URL helpers in controllers are not included properly if defined before initialization)

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end

class ApplicationController < ActionController::Base
end

class ApplicationJob < ActiveJob::Base
end

class ApplicationMailer < ActionMailer::Base
  layout nil

  after_action :prevent_delivery

  private

  # Do not attempt deliveries, just print a message
  def prevent_delivery
    message.perform_deliveries = false
    puts "[EMAIL SENT] to=#{message.to&.join(",")} subject=#{message.subject} body=#{message.body}"
  end
end

class WelcomeController < ApplicationController
  def index
    head :ok
  end
end
