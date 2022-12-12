require_relative "./prelude"

module Contactable
  extend ActiveSupport::Concern

  SOCIAL_ACCOUNTS = %i[facebook twitter tiktok].freeze

  included do
    store_accessor :social_accounts, *SOCIAL_ACCOUNTS,
                   suffix: :social_id

    validates :phone_number, allow_blank: true,
                             phone: {types: :mobile}
    validates :country_code, inclusion: Country.codes

    before_validation :normalize_phone_number,
                      if: :phone_number_changed?
  end

  def region = Country[country_code].region

  def phone_number_visible?
    contact_info_visible && phone_number_visible
  end

  def normalize_phone_number
    return unless phone_number.present?

    self.phone_number = Phonelib.parse(phone_number).e164
  end
end

class User < ApplicationRecord
  include Contactable
end

user = User.new(
  name: "Alice", country_code: "US", phone_number: "+1 (234) 444-5555",
  twitter_social_id: "alice555"
)

user.save!

puts user.phone_number

puts user.region
