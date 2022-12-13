require_relative "./prelude"

class User < ApplicationRecord
  store :address, coder: JSON
end

user = User.create!(address: {country: "USA", city: "Bronx", street: "231st", zip: 10463})

user.address
