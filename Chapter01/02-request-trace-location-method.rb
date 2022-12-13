require_relative "./prelude"

request = Rack::MockRequest.env_for("http://localhost:3000")

TraceLocation.trace(format: :log, methods: [:call]) do
  Rails.application.call(request)
end
