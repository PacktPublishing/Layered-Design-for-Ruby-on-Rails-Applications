# frozen_string_literal: true

class PureFlash::Component
  attr_reader :alert, :notice

  def initialize(alert: nil, notice: nil)
    @alert = alert
    @notice = notice
  end

  def render_in(view_context)
    view_context.render(partial: "components/pure_flash/component", locals: {c: self})
  end

  def format = :html
end
