# We don't need logs for this example # :ignore:
$logging = false

# Define routes before loading prelude
require_relative "../lib/helpers"
using ChapterHelpers

routes do # :ignore:output
  direct :imgproxy_active_storage do |model, options|
    expires_in = options.delete(:expires_in) { ActiveStorage.urls_expire_in }

    # Serve originals via the built-in Rails proxy
    if model.respond_to?(:signed_id)
      route_for(
        :rails_service_blob_proxy,
        model.signed_id(expires_in:),
        model.filename,
        options
      )
    else
      options = {expires: expires_in, filename: model.filename}
      # options.merge!(Imgproxy.variation_to_params(model.variation))
      model.blob.imgproxy_url(**options)
    end
  end
end

require_relative "./prelude"

# Add avatar to users
class User < ApplicationRecord
  has_one_attached :avatar
end

image = File.open(File.join(__dir__, "assets/me.png"))
user = User.create!(name: "Vova")
user.avatar.attach(io: image, filename: "me.png")

puts url_for user.avatar

puts url_for user.avatar.variant(resize: "200x150")

# Now let's add imgproxy integration
Imgproxy.configure do |config|
  config.endpoint = "https://imgproxy.example.com"
  config.key = "secret"
  config.salt = "pepper"
  config.base64_encode_urls = true
end

Imgproxy.extend_active_storage! # :ignore:output

ActiveStorage.resolve_model_to_route = :imgproxy_active_storage

puts url_for user.avatar

puts url_for user.avatar.variant(resize: "200x150")
