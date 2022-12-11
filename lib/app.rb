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

class WelcomeController < ApplicationController
  def index
    render inline: 'Hi!'
  end
end
