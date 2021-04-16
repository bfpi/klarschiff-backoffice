# frozen_string_literal: true

module CoreExtensions
  class ::String
    def to_boolean
      (v = YAML.safe_load(self)) && (v.is_a?(TrueClass) || v.is_a?(FalseClass))
    end

    def i?
      match?(/\A[-+]?\d+\z/)
    end
  end

  class ::Integer
    def i?
      true
    end
  end
end
