require_relative "./prelude"
using ChapterHelpers

class UserInvitationForm
  attr_reader :user, :send_copy, :sender
  def initialize(params, send_copy: false, sender: nil)
    @user = User.new(params)
    @send_copy = send_copy.in?(%w[1 t true])
    @sender = sender
  end

  def save
    validate!
    return false if user.errors.any?

    user.save!
    deliver_notifications!
  end

  private

  def validate!
    user.errors.add(:email, :blank) if user.email.blank?
  end

  def deliver_notifications!
    UserMailer.invite(user).deliver_later
    if send_copy
      UserMailer.invite_copy(sender, user).deliver_later
    end
  end
end

class InvitationsController < ApplicationController # :ignore:
  def new
    @user = User.new
  end

  def create
    form = UserInvitationForm.new(
      params.require(:user).permit(:email).to_h,
      send_copy: params[:send_copy],
      sender: current_user
    )

    if form.save
      redirect_to root_path
    else
      @user = form.user
      render :new, status: :unprocessable_entity
    end
  end
end

current_user = User.create!(email: "admin@local.test", name: "Admin")
post "/invitations", params: {user: {email: "palkan@evl.ms"}, send_copy: "1"}, cookies: {user_id: current_user.id}

User.find_by!(email: "palkan@evl.ms")

response = post "/invitations", params: {user: {email: ""}, send_copy: "1"}, cookies: {user_id: current_user.id}
puts response.body
