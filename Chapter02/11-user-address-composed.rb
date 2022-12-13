require_relative "./prelude"

class User < ApplicationRecord
  composed_of :address,
    class_name: "User::Address",
    mapping: [%w[address_country], %w[address_city], %w[address_street], %w[address_zip]],
    constructor: proc { |country, city, street, zip|
      Address.new({country:, city:, street:, zip:})
    }
end

class User::Address
  include ActiveModel::API
  include ActiveModel::Attributes

  attribute :country
  attribute :city
  attribute :street
  attribute :zip
end

user = User.create!(address_country: "UK", address_city: "Birmingham", address_street: "Livery st", address_zip: "B32PB")

user.address.zip
