require_relative "./prelude"

class ContactInformation < ApplicationRecord
  belongs_to :contactable, polymorphic: true

  SOCIAL_ACCOUNTS = %i[facebook twitter tiktok].freeze
  store_accessor :social_accounts, *SOCIAL_ACCOUNTS,
    suffix: :social_id

  validates :phone_number, allow_blank: true,
    phone: {types: :mobile}
  validates :country_code, inclusion: Country.codes

  before_validation :normalize_phone_number,
    if: :phone_number_changed?

  def region
    Country[country_code].region
  end

  private

  def phone_number_visible?
    contact_info_visible && phone_number_visible
  end

  def normalize_phone_number
    return unless phone_number.present?

    self.phone_number = Phonelib.parse(phone_number).e164
  end
end

module Contactable
  extend ActiveSupport::Concern

  included do
    has_one :contact_information, as: :contactable,
      dependent: :destroy

    delegate :phone_number, :region,
      to: :contact_information
  end
end

class User < ApplicationRecord
  include Contactable
end

user = User.new(
  name: "Alice"
)
user.save!

user.create_contact_information(
  country_code: "US",
  phone_number: "+1 (234) 444-5555",
  twitter_social_id: "alice555"
)

puts user.phone_number

puts user.region
