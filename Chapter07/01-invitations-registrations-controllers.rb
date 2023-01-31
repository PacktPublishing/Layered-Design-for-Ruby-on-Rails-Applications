require_relative "./prelude"
using ChapterHelpers

class InvitationsController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(params.require(:user).permit(:email))

    if @user.save
      redirect_to root_path
    else
      render :new, status: :unprocessable_entity
    end
  end
end

class RegistrationsController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(params.require(:user).permit(:email, :name))
    @user.confirmed_at = Time.current

    if @user.save
      redirect_to root_path
    else
      render :new, status: :unprocessable_entity
    end
  end
end

class User < ApplicationRecord
  validates :email, presence: true, uniqueness: true
  validates :name, presence: true, if: :confirmed?

  def confirmed? = confirmed_at.present?
end

response = get "/invitations/new"
puts response.body

post "/invitations", params: {user: {email: "palkan@evl.ms"}}

invited_user = User.find_by!(email: "palkan@evl.ms")
invited_user.confirmed?

response = get "/registrations/new"
puts response.body

post "/registrations", params: {user: {name: "Vova", email: "palkan@evilmartians.com"}}
response.status

registered_user = User.find_by!(email: "palkan@evilmartians.com")
registered_user.confirmed?

# Adding notifications
class User < ApplicationRecord
  after_create_commit :send_invitation, unless: :confirmed?
  after_create_commit :send_welcome_email, if: :confirmed?

  def send_invitation
    UserMailer.invite(self).deliver_later
  end

  def send_welcome_email
    UserMailer.welcome(self).deliver_later
  end
end

post "/invitations", params: {user: {email: "palkan+notify@evl.ms"}}

post "/registrations", params: {user: {name: "Vova 2", email: "palkan+notify@evilmartians.com"}}

# Add virtual attributes to control notifications
class User < ApplicationRecord
  attribute :should_send_invitation, :boolean
  attribute :should_send_welcome_email, :boolean

  after_create_commit :send_invitation, if: :should_send_invitation
  after_create_commit :send_welcome_email, if: :should_send_welcome_email
end

class InvitationsController < ApplicationController
  def create
    @user = User.new(params.require(:user).permit(:email))
    @user.should_send_invitation = true

    if @user.save
      redirect_to root_path
    else
      render :new, status: :unprocessable_entity
    end
  end
end

class RegistrationsController < ApplicationController
  def create
    @user = User.new(params.require(:user).permit(:email, :name))
    @user.confirmed_at = Time.current
    @user.should_send_welcome_email = true

    if @user.save
      redirect_to root_path
    else
      render :new, status: :unprocessable_entity
    end
  end
end

post "/invitations", params: {user: {email: "palkan+notify+attributes@evl.ms"}}

post "/registrations", params: {user: {name: "Still Vova", email: "palkan+notify+attributes@evilmartians.com"}}

# Send a copy of invitation to the current user
current_user = User.create!(email: "admin@local.test", name: "Admin")

class InvitationsController < ApplicationController
  def create
    @user = User.new(params.require(:user).permit(:email))
    @user.should_send_invitation = true

    if @user.save
      if params[:send_copy] == "1"
        UserMailer.invite_copy(current_user, @user)
          .deliver_later
      end
      redirect_to root_path
    else
      render :new, status: :unprocessable_entity
    end
  end
end

post "/invitations", params: {user: {email: "palkan+notify+copy@evl.ms"}, send_copy: "1"}, cookies: {user_id: current_user.id}
