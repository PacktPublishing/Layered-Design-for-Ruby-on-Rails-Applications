require_relative "./prelude"
using ChapterHelpers

# This example file is meant to be used with a Rails server to see the updated search box UI.
# Run the server and choose the 03-xxx example:
#  CHAPTER=11 bin/rails s

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

results = Result.all

binding.render <<~ERB
  <%- @results = results -%>
  <%= render template: "results/index" %>
ERB
