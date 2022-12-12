require_relative "./prelude"

class User < ApplicationRecord
  has_secure_password

  def self.authenticate_by(email:, password:)
    find_by(email:)&.authenticate(password)
  end
end

user = User.create!(
  name: "Secret User", email: "secret@example.com",
  password: "secret", password_confirmation: "secret"
)

authenticated_user = User.authenticate_by(email: "secret@example.com", password: "secret")

user == authenticated_user
