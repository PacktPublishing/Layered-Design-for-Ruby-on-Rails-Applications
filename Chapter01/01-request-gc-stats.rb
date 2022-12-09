require_relative "./prelude"

request = Rack::MockRequest.env_for('http://localhost:3000')

was_alloc = GC.stat[:total_allocated_objects]

Rails.application.call(request)

new_alloc = GC.stat[:total_allocated_objects]
puts "Total allocations: #{new_alloc - was_alloc}"
