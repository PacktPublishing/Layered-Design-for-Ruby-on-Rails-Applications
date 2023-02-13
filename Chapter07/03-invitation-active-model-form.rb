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

class InvitationForm < ApplicationForm
  attribute :email
  attribute :send_copy, :boolean

  attr_accessor :sender

  validates :email, presence: true

  after_commit :deliver_invitation
  after_commit :deliver_invitation_copy, if: :send_copy

  private

  attr_reader :user

  def submit!
    @user = User.new(email:)
    user.save!
  end

  def deliver_invitation
    UserMailer.invite(user).deliver_later
  end

  def deliver_invitation_copy
    UserMailer.invite_copy(sender, user).deliver_later if sender
  end
end

class InvitationsController < ApplicationController
  def new
    @invitation_form = InvitationForm.new
  end

  def create
    @invitation_form = InvitationForm.new(
      params.require(:invitation).permit(:email, :send_copy)
    )
    @invitation_form.sender = current_user

    if @invitation_form.save
      redirect_to root_path
    else
      render :new, status: :unprocessable_entity
    end
  end
end

current_user = User.create!(email: "admin@local.test", name: "Admin")
post "/invitations", params: {invitation: {email: "palkan@evl.ms", send_copy: "1"}}, cookies: {user_id: current_user.id}

User.find_by!(email: "palkan@evl.ms")

# Making friends with Action View
class ApplicationForm
  def model_name
    ActiveModel::Name.new(nil, nil, self.class.name.sub(/Form$/, ""))
  end
end

response = get "/invitations/new"
puts response.body

# Making friends with strong parameters
class ApplicationForm
  class << self
    def from(params)
      new(params.permit(attribute_names.map(&:to_sym)))
    end
  end
end

class InvitationsController < ApplicationController
  def create
    @invitation_form = InvitationForm.from(params.require(:invitation))
    @invitation_form.sender = current_user

    if @invitation_form.save
      redirect_to root_path
    else
      render :new, status: :unprocessable_entity
    end
  end
end

post "/invitations", params: {invitation: {email: "palkan+2@evl.ms"}}, cookies: {user_id: current_user.id}

User.find_by!(email: "palkan+2@evl.ms")
