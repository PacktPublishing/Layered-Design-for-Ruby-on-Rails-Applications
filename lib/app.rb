# frozen_string_literal: true

# Define base classes for the app.
# Must be declared after application initialization to work correctly
# (for example, URL helpers in controllers are not included properly if defined before initialization)

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end

class ApplicationController < ActionController::Base
  helper_method :current_user
  layout -> { (request.headers["X-WITHIN-EXAMPLE"] == "true") ? false : "application" }

  def current_user
    return @current_user if instance_variable_defined?(:@current_user)

    @current_user = User.find_by(id: cookies[:user_id])
  end
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
    reply_to = message.reply_to ? "reply_to=#{message.reply_to.join(",")} " : ""
    puts "[EMAIL SENT] to=#{message.to&.join(",")} #{reply_to}subject=#{message.subject} body=#{message.body}"
  end
end

class WelcomeController < ApplicationController
  def index
  end
end
