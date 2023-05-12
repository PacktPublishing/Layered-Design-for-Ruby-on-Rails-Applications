require_relative "./prelude"
using ChapterHelpers

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

module UIHelper
  def search_box(url:, placeholder: "Search", variant: :full)
    form_with(url:, class: "relative mb-4 flex w-full shadow-sm flex-wrap items-stretch") do |f|
      concat(content_tag(:div, "", class: "absolute z-[2] inset-y-4 left-0 flex items-center pl-3 pointer-events-none w-5 h-5") do
        content_tag(:i, "", class: "fa fa-search text-gray-400")
      end)
      concat f.text_field :q, placeholder:, class: "min-w-0 flex-auto relative block rounded border border-gray-200 outline-none px-3 py-3 focus:border-blue-300 placeholder-gray-400 pl-10"
      if variant == :full
        concat f.submit "Search", class: "absolute right-2.5 bottom-2.5 rounded p-1.5 px-2 text-sm bg-blue-600 text-white inline-block font-medium cursor-pointer hover:bg-blue-500 active:bg-blue-700"
      end
    end
  end
end

# Register heleprs manually (Rails loads them from app/helpers) # :ignore:
ApplicationController.helper UIHelper

binding.render <<~ERB
  <%= search_box(url: search_results_path, placeholder: "Search results", variant: :compact) %>
ERB

binding.render <<~ERB
  <%= search_box(url: search_results_path, placeholder: "Search results", variant: :full) %>
ERB
