require_relative "./prelude"

# Extract user authentication concern into app/concerns/user/authentication.rb
module User::Authentication
  extend ActiveSupport::Concern

  included do
    has_secure_password
  end

  class_methods do
    def authenticate_by(email:, password:)
      find_by(email:)&.authenticate(password)
    end
  end
end

class User < ApplicationRecord
  include Authentication
end

user = User.create!(
  name: "Secret User", email: "secret@example.com",
  password: "secret", password_confirmation: "secret"
)

authenticated_user = User.authenticate_by(email: "secret@example.com", password: "secret")

user == authenticated_user
