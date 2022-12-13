require_relative "./prelude"

class User < ApplicationRecord
  after_commit :send_welcome_email, on: :create

  private

  def send_welcome_email
    UserMailer.welcome(self).deliver_later
  end
end

User.create!(name: "Vova")

# Define more callbacks
class User < ApplicationRecord
  after_create :generate_initial_project
  after_commit :send_welcome_email, on: :create
  after_commit :send_analytics_event, on: :create
  after_commit :sync_with_crm

  private

  def generate_initial_project
    puts "[INTERNAL] Generate project for #{name} (#{id})"
  end

  def send_analytics_event
    puts "[ANALYTICS] User created: ID=#{id}"
  end

  def sync_with_crm
    puts "[CRM] Create user: NAME=#{name}"
  end
end

User.create!(name: "John")

# Add conditions to some callbacks
class User < ApplicationRecord
  after_create :generate_initial_project, unless: :admin?
  after_commit :send_welcome_email, on: :create
  after_commit :send_analytics_event,
    on: :create, if: :tracking_consent?
  after_commit :sync_with_crm
end

User.create!(name: "Non-admin without consent", admin: false, tracking_consent: false)

User.create!(name: "Non-admin with consent", admin: false, tracking_consent: true)

User.create!(name: "Admin without consent", admin: true, tracking_consent: false)

# Add virtual attributes to skip callbacks
class User < ApplicationRecord
  attr_accessor :skip_welcome_email, :skip_crm_sync
  after_create :generate_initial_project, unless: :admin?
  after_commit :send_welcome_email,
    on: :create, unless: :skip_welcome_email
  after_commit :send_analytics_event,
    on: :create, if: :tracking_consent?
  after_commit :sync_with_crm, unless: :skip_crm_sync
end

User.create!(name: "Non-admin with consent",
  admin: false, tracking_consent: true,
  skip_crm_sync: true, skip_welcome_email: true)
