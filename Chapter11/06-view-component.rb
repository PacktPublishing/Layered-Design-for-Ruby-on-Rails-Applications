require_relative "./prelude"
using ChapterHelpers

# Make it possible to use `render` anywhere
using(Module.new do # :ignore:
  refine Object do
    def render(*, **) = ApplicationController.render(*, layout: nil, **)
  end
end)

# Populate data
user = User.create!(name: "Vova Dem")
alice = User.create!(name: "Alice")
course = Course.create!(title: "Layered Rails", category: "Web Dev")
quiz = course.quizzes.create(title: "Active Record basics", max_attempts: 1, score: 6)
quiz_vc = course.quizzes.create(title: "View components", max_attempts: 2, score: 9)
course.students << user
course.students << alice
result = quiz.results.create!(user: alice, score: 5, passed: true, created_at: 4.days.ago)
result2 = quiz_vc.results.create!(user:, score: 2, passed: false, created_at: 233.hours.ago)
result3 = quiz_vc.results.create!(user:, attempt: 2, score: 7, passed: true, created_at: 453.minutes.ago)

class ApplicationViewComponent < ViewComponent::Base
end

class SearchBox::Component < ApplicationViewComponent
  attr_reader :url, :placeholder

  def initialize(
    url:, placeholder: "Search", variant: :full
  )
    @url = url
    @placeholder = placeholder
    @variant = variant
  end

  private def button? = @variant == :full
end

render SearchBox::Component.new(url: "#")

class ApplicationViewComponent < ViewComponent::Base
  extend Dry::Initializer[undefined: false]
end

class SearchBox::Component < ApplicationViewComponent
  option :url
  option :placeholder, optional: true
  option :variant, default: proc { :full }

  def before_render
    raise ArgumentError, "Unknown variant: #{variant}" unless %i[full compact].include?(variant)
    @placeholder ||= t(".placeholder")
  end

  private def button? = variant == :full
end

render SearchBox::Component.new(url: "#", variant: :compact)

begin
  render SearchBox::Component.new(url: "#", variant: :another)
rescue => err
  puts err.message
end

require "rails/test_help"
require "view_component/test_helpers"

class SearchBox::ComponentTest < ViewComponent::TestCase
  def test_render_default_full
    render_inline(
      SearchBox::Component.new(
        url: "#", placeholder: "Search things"
      )
    )

    assert_selector "input[type='submit']"
    assert_selector "input[type='search'][placeholder='Search things']"
  end

  def test_render_compact
    render_inline(SearchBox::Component.new(url: "#", variant: :compact))

    assert_no_selector "input[type='submit']"
  end
end

Minitest.run
