# frozen_string_literal: true

begin
  require 'bigdecimal'
rescue LoadError
end

if defined?(::BigDecimal)
  # This provides a simpler serialization that outputs BigDecimal as plain numbers
  class BigDecimal
    # Override as_json to return self instead of converting to a string.
    # This prevents unexpected behaviors like:
    #   BigDecimal("1.12345678912345678912345").as_json + 5 # => TypeError
    def as_json(*)
      self
    end

    # Override to_json to serialize BigDecimal as a plain decimal number.
    # This outputs the BigDecimal value directly as a JSON number with full precision,
    # rather than as a quoted string or in scientific notation.
    def to_json(state = nil, *)
      to_s('F')
    end
  end
end
