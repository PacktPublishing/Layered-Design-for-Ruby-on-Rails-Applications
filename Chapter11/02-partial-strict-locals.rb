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
course = Course.create!(title: "Layered Rails", category: "Web Dev")
quiz = course.quizzes.create(title: "Active Record basics", max_attempts: 1, score: 6)

course.students << user

result = quiz.results.create!(user:, score: 5, passed: true, created_at: 4.days.ago)

begin
  render partial: "quizzes/student_result", locals: {}
rescue => err
  puts err.message
end

begin
  render partial: "quizzes/student_result", locals: {quiz:, result:, foo: "bar"}
rescue => err
  puts err.message
end
