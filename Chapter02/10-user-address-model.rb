require_relative "./prelude"

class User < ApplicationRecord
  store :address, coder: JSON

  def address = @address ||= Address.new(super)
end

class User::Address
  include ActiveModel::API
  include ActiveModel::Attributes

  attribute :country
  attribute :city
  attribute :street
  attribute :zip
end

user = User.create!(address: {country: "USA", city: "Bronx", street: "231st", zip: 10463})

user.address

# Adding validations to the address model
class User::Address
  validates :country, :zip, presence: true
end

class User < ApplicationRecord
  validate do |record|
    next if address.valid?
    record.errors.add(:address, "is invalid")
  end
end

user = User.create(address: {})

user.valid?

user.errors.full_messages
