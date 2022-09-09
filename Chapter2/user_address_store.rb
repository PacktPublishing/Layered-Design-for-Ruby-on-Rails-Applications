# frozen_string_literal: true

require_relative "../lib/application"

ActiveRecord::Schema.define do
  create_table :users, force: true do |t|
    t.text :address, null: false
    t.timestamps null: true
  end
end

class User < ApplicationRecord
  class Address
    include ActiveModel::API
    include ActiveModel::Attributes

    attribute :country
    attribute :city
    attribute :street
    attribute :zip

    validates :country, :zip, presence: true
  end

  store :address, coder: JSON

  validate do |record|
    next if record.address.valid?
    record.errors.add(:address, "is invalid")
  end

  def address() = @address ||= Address.new(super)
end

user = User.create(address: {country: 'USA', city: 'Bronx', street: '231st', zip: 10463})
user.address.zip #=> 10463

another_user = User.create(address: {})
user.valid? #=> false
