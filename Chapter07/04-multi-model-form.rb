require_relative "./prelude"
using ChapterHelpers

class ApplicationForm
  include ActiveModel::API
  include ActiveModel::Attributes

  define_callbacks :save, only: :after
  define_callbacks :commit, only: :after

  class << self
    def after_save(...)
      set_callback(:save, :after, ...)
    end

    def after_commit(...)
      set_callback(:commit, :after, ...)
    end
  end

  def save
    return false unless valid?

    with_transaction do
      AfterCommitEverywhere.after_commit { run_callbacks(:commit) }
      run_callbacks(:save) { submit! }
    end
  end

  private

  def with_transaction(&) = ApplicationRecord.transaction(&)

  def submit!
    raise NotImplementedError
  end
end

class User < ApplicationRecord
  validates :email, :name, presence: true
end

class RegistrationForm < ApplicationForm
  attribute :name
  attribute :email
  attribute :should_create_project, :boolean
  attribute :project_name

  validates :project_name, presence: true, if: :should_create_project

  attr_reader :user

  after_save :create_initial_project, if: :should_create_project

  private

  def submit!
    @user = User.create!(email:, name:)
  end

  def create_initial_project
    user.projects.create!(name: project_name)
  end
end

form = RegistrationForm.new(
  {name: "Vova", email: "vova@rails.test", project_name: "Rails Cake", should_create_project: "t"}
)

form.save

puts Project.find_by(name: "Rails Cake").user.name

begin
  RegistrationForm.new(name: "Test").save
rescue ActiveRecord::RecordInvalid => e
  puts "#{e.class}: #{e.message}"
end
# Errors delegation
class ApplicationForm
  def merge_errors!(other)
    other.errors.each do |e|
      errors.add(e.attribute, e.type, message: e.message)
    end
  end
end

class RegistrationForm < ApplicationForm
  validate :user_is_valid

  def initialize(...)
    super
    @user = User.new(email:, name:)
  end

  private

  def submit!
    user.save!
  end

  def user_is_valid
    return if user.valid?
    merge_errors!(user)
  end
end

form = RegistrationForm.new(name: "Test")
form.save

puts form.errors.full_messages
