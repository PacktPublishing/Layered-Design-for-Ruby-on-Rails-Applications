require_relative "./prelude"
using ChapterHelpers

class UserMailer < ApplicationMailer
  def welcome(user)
    @user = user
    mail(
      to: @user.email,
      subject: "Welcome to the club!"
    )
  end
end

user = User.create!(name: "Vova", email: "me@example.test")

UserMailer.welcome(user).deliver_later
