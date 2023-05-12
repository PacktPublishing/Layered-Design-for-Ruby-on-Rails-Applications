require_relative "../lib/helpers"
using ChapterHelpers

gems do
  gem "view_component", "~> 3.0"
  gem "view_component-contrib", "~> 0.1.4"
  gem "dry-initializer", "3.1.1"
  gem "capybara", "~> 3.39"

  gem "benchmark-ips", "2.10.0"
  gem "benchmark-memory", "0.2.0"
end

schema do
  create_table :users, force: true do |t|
    t.string :name, null: true
    t.timestamps
  end

  create_table :courses, force: true do |t|
    t.string :title, null: false
    t.string :category, null: false
    t.integer :students_count, null: false, default: 0
    t.timestamps
  end

  create_table :assignments, force: true do |t|
    t.belongs_to :course, null: false
    t.belongs_to :user, null: false
    t.timestamps
  end

  create_table :quizzes, force: true do |t|
    t.belongs_to :course, null: false
    t.string :title, null: false
    t.integer :score, null: false, default: 0
    t.integer :max_attempts, null: false, default: 1
    t.timestamps
  end

  create_table :results, force: true do |t|
    t.belongs_to :quiz, null: false
    t.belongs_to :user, null: false
    t.integer :score, null: false, default: 0
    t.integer :attempt, null: false, default: 1
    t.boolean :passed, null: false, default: false
    t.timestamps
  end
end

routes do
  resources :results, only: [:index] do
    post :search, on: :collection, as: :search
  end

  resources :users, only: [:show]
  resources :courses, only: [:show]
end

require_relative "../lib/boot"

class User < ApplicationRecord
  has_many :assignments, dependent: :destroy, inverse_of: :user
  has_many :courses, through: :assignments
end

class Course < ApplicationRecord
  has_many :quizzes, dependent: :destroy, inverse_of: :course
  has_many :assignments, dependent: :destroy, inverse_of: :course
  has_many :students, through: :assignments, source: :user
end

class Assignment < ApplicationRecord
  belongs_to :user
  belongs_to :course, counter_cache: :students_count
end

class Quiz < ApplicationRecord
  belongs_to :course
  has_many :results, dependent: :destroy, inverse_of: :quiz
end

class Result < ApplicationRecord
  belongs_to :quiz
  belongs_to :user
end

# Only used to preview partials in the browser
class ResultsController < ApplicationController
  def index
    @results = Result.all
  end

  def search
    @results =
      if params[:q].present?
        Result.joins(:user, :quiz).where("users.name LIKE ?", "%#{params[:q]}%").or(
          Result.joins(:user, :quiz).where("quizzes.title LIKE ?", "%#{params[:q]}%")
        )
      else
        Result.all
      end
    render action: :index
  end
end

class UsersController < ApplicationController
  def show = render plain: "Not implemented"
end

class CoursesController < ApplicationController
  def show = render plain: "Not implemented"
end
