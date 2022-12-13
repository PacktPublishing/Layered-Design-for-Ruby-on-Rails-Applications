require_relative "./prelude"
using ChapterHelpers

# Application controller with around callbacks to set up
# the request local and time zone
class ApplicationController < ActionController::Base
  around_action :with_current_locale
  around_action :with_current_tz, if: :current_user

  private

  def with_current_locale(&)
    locale = params[:locale] || current_user&.locale || I18n.default_locale

    I18n.with_locale(locale, &)
  end

  def with_current_tz(&)
    Time.use_zone(current_user.time_zone, &)
  end

  # Dummy current_user implementation
  def current_user
    OpenStruct.new(locale: params[:lang], time_zone: params[:tz])
  end
end

# Dummy controller to see contextual callbacks in action
class DemosController < ApplicationController
  def show
    render inline: t("current_time", time: Time.zone.now)
  end
end

response = get "/demo?lang=en&tz=America/New_York"

puts response.body

response = get "/demo?lang=ru&tz=Asia/Magadan"

puts response.body
