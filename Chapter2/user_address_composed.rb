# frozen_string_literal: true

require_relative "../lib/application"

ActiveRecord::Schema.define do
  create_table :users, force: true do |t|
    t.string :address_country, null: false
    t.string :address_city
    t.string :address_street
    t.string :address_zip, null: false
    t.timestamps null: true
  end
end

class User < ApplicationRecord
  class Address
    include ActiveModel::API
    include ActiveModel::Attributes

    def self.compose_mapping(prefix) = attribute_names.map { ["#{prefix}_#{_1}", _1] }
    def self.compose(*attrs) = new(Hash[attribute_names.map.with_index { [_1, attrs[_2]] }])

    attribute :country
    attribute :city
    attribute :street
    attribute :zip

    validates :country, :zip, presence: true
  end

  composed_of :address,
    class_name: "User::Address",
    mapping: Address.compose_mapping("address"),
    constructor: :compose

  validate do |record|
    next if record.address.valid?
    record.errors.add(:address, "is invalid")
  end
end

user = User.create!(address_country: "UK", address_city: "Birmingham", address_street: "Livery st", address_zip: "B32PB")
user.address.zip #=> B32PB

another_user = User.create(address_country: "", address_zip: "")
user.valid? #=> false
