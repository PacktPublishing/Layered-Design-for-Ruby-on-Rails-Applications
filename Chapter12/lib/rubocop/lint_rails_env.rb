module RuboCop
  module Cop
    module Lint
      class RailsEnv < RuboCop::Cop::Cop
        MSG = "Avoid Rails.env in application code, " \
              "use configuration parameters instead"

        def_node_matcher :rails_env?, <<~PATTERN
          (send {(const nil? :Rails) (const (cbase) :Rails)} :env)
        PATTERN

        def on_send(node)
          return unless rails_env?(node)
          add_offense(
            (node.parent.type == :send) ? node.parent : node,
            location: :selector, message: MSG
          )
        end
      end
    end
  end
end
