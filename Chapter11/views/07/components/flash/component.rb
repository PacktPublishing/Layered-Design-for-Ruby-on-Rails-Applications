# frozen_string_literal: true

# We only need to initialize it here to get the correct source location,
# used to lookup templates
class SearchBox::Component < ApplicationViewComponent
  option :alert
  option :notice
end
