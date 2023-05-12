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

class SearchBox::Component
  attr_reader :action, :placeholder

  def initialize(
    action:, placeholder: "Search", variant: :full
  )
    @action = action
    @placeholder = placeholder
    @variant = variant
  end

  def button? = @variant == :full

  def render_in(view_context)
    view_context.render(partial: "components/search_box/component", locals: {c: self})
  end

  def format = :html
end

render SearchBox::Component.new(action: "#")

render SearchBox::Component.new(action: "#", variant: :short)

class SearchBox::Component
  def render_in(view_context)
    view_context.render(inline: template, locals: {search_box: self})
  end

  def template
    <<~'ERB'
      <%= form_with(url: search_box.action, class: "relative mb-4 flex w-full shadow-sm flex-wrap items-stretch") do |f| %>
        <div class="absolute z-[2] inset-y-4 left-0 flex items-center pl-3 pointer-events-none w-5 h-5">
          <i class="fa fa-search text-gray-400"></i>
        </div>
        <%= f.search_field :q, placeholder: search_box.placeholder, required: true, class: "min-w-0 flex-auto relative block rounded border border-gray-200 outline-none px-3 py-3 focus:border-blue-300 placeholder-gray-400 pl-10" %>
        <% if search_box.button? %>
          <%= f.submit "Search", class: "absolute right-2.5 bottom-2.5 rounded p-1.5 px-2 text-sm bg-blue-600 text-white inline-block font-medium cursor-pointer hover:bg-blue-500 active:bg-blue-700" %>
        <% end %>
      <% end %>
    ERB
  end
end

render SearchBox::Component.new(action: "#")

render SearchBox::Component.new(action: "#", variant: :short)
