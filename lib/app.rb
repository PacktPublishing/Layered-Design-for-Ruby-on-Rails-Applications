# frozen_string_literal: true

# Define base classes for the app.
# Must be declared after application initialization to work correctly
# (for example, URL helpers in controllers are not included properly if defined before initialization)

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end

module ApplicationHelper
end

class Current < ActiveSupport::CurrentAttributes
  attribute :user
end

class ApplicationController < ActionController::Base
  helper_method :current_user
  layout -> { request.headers["X-EXAMPLE"].present? ? false : "application" }

  before_action :configure_example_view_path

  def current_user
    return @current_user if instance_variable_defined?(:@current_user)

    @current_user = Current.user || User.find_by(id: cookies[:user_id])
  end

  private

  def current_chapter
    return @current_chapter if @current_chapter

    chapter = ENV.fetch("CHAPTER") do
      request.headers["X-CHAPTER"]
    end&.rjust(2, "0")

    @current_chapter = chapter ? Chapter.new(chapter) : nil

    return unless @current_chapter

    example = request.headers["X-EXAMPLE"].presence
    @current_chapter.find_example(example)&.then(&:active!) if example

    @current_chapter
  end

  def configure_example_view_path
    return unless current_chapter&.active_example

    prepend_view_path File.join(current_chapter.root, "views", current_chapter.active_example.id)
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

    def loaded?
      return @active if instance_variable_defined?(:@active)

      @active = $LOADED_FEATURES.include?(path)
    end

    def active! = @active = true

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
      end.tap(&:uniq!).tap(&:sort!)
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
    ActiveRecord::Tasks::DatabaseTasks.truncate_all

    Thread.new {
      sleep 1
      server.begin_restart
    }

    redirect_to root_path
  end
end

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :user

    def connect
      self.user = User.find_by(id: request.params[:user_id])
      reject_unauthorized_connection unless user
    end
  end

  class Channel < ActionCable::Channel::Base
  end
end
