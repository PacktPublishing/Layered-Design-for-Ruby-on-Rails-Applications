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

class Chapter
  class Example
    attr_reader :path, :name, :id

    def initialize(path)
      @path = path

      filename = File.basename(path)

      filename.match(/^(?<id>\d+)-(?<name>.+)\.rb$/) => {id:, name:}

      @id = id
      @name = name.tr("-", "_").titleize
    end

    def loaded? = @active ||= $LOADED_FEATURES.include?(path)

    def to_s = name

    def to_param = id

    def load
      Kernel.require(path)
    end
  end

  class Router
    attr_reader :routes

    def initialize(routes = Rails.application.routes)
      @routes = routes
    end

    def paths
      @paths ||= routes.set.routes.filter_map do
        path = _1.path.spec.to_s
        next if path.starts_with?("/rails")
        next if path.starts_with?("/_/")
        next if path == "/"
        path.sub(%r{\(.:format\)}, "")
      end.uniq!.sort!
    end

    def recognizable_paths
      paths.select do
        routes.recognize_path(_1)
    rescue
      false
      end
    end
  end

  attr_reader :root, :id

  def initialize(num)
    @id = num.to_i
    @root = File.expand_path(File.join(__dir__, "../Chapter#{num}"))
  end

  def router = Router.new

  def examples
    @examples ||= Dir.glob(File.join(root, "*.rb")).filter_map do |path|
      next unless path.match?(/\/\d{2}-/)

      Example.new(path)
    end
  end

  def find_example(id)
    examples.find { _1.id == id }
  end

  def active_example
    return @active_example if instance_variable_defined?(:@active_example)

    @active_example = examples.find(&:loaded?)
  end
end

class WelcomeController < ApplicationController
  helper_method :current_chapter

  def index
  end

  def load_example
    example = current_chapter&.find_example(params[:id])

    example&.load

    redirect_to root_path
  end

  def reset_examples
    server = Puma::Server.current
    Thread.new {
      sleep 1
      server.begin_restart
    }

    redirect_to root_path
  end

  private

  def current_chapter
    return @current_chapter if @current_chapter

    @current_chapter =
      if ENV["CHAPTER"]
        Chapter.new(ENV["CHAPTER"].rjust(2, "0"))
      end
  end
end
