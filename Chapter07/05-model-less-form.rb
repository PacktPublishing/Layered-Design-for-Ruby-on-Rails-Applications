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

    def from(params)
      new(params.permit(attribute_names.map(&:to_sym)))
    end
  end

  def save
    return false unless valid?

    with_transaction do
      AfterCommitEverywhere.after_commit { run_callbacks(:commit) }
      run_callbacks(:save) { submit! }
    end
  end

  def model_name
    ActiveModel::Name.new(nil, nil, self.class.name.sub(/Form$/, ""))
  end

  private

  def with_transaction(&) = ApplicationRecord.transaction(&)

  def submit!
    raise NotImplementedError
  end
end

class FeedbackForm < ApplicationForm
  attribute :name
  attribute :email
  attribute :message

  validates :name, :email, :message, presence: true
  validates :message, length: {maximum: 160}

  after_commit do
    SystemMailer.feedback(email, name, message).deliver_later
  end

  def submit! = true
end

form = FeedbackForm.new(
  name: "Alice",
  email: "alice@example.com",
  message: "Help, I need somebody, not just anybody"
)

form.save

class FeedbacksController < ApplicationController
  def new
    @feedback_form = FeedbackForm.new
  end

  def create
    @feedback_form = FeedbackForm.from(params.require(:feedback))
    if @feedback_form.save
      redirect_to root_path
    else
      render :new, status: :unprocessable_entity
    end
  end
end
