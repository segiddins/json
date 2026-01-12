# frozen_string_literal: true
require_relative 'test_helper'

begin
  require 'bigdecimal'
rescue LoadError
end

class JSONBigDecimalTest < Test::Unit::TestCase
  def test_preserves_bigdecimals_when_parsing_json_with_decimal_numbers
    big_decimal = BigDecimal('1.12345678912345678912345')
    json_string = '{"amount": 1.12345678912345678912345}'
    parsed = JSON.parse(json_string)

    assert_instance_of(BigDecimal, parsed['amount'])
    assert_equal(big_decimal, parsed['amount'])
  end if defined?(::BigDecimal)

  # Note: as_json is a Rails-specific feature, not part of standard Ruby
  # This test is skipped for now

  def test_serializes_bigdecimals_as_decimal_numbers_not_strings_in_to_json
    big_decimal = BigDecimal('1.12345678912345678912345')
    hash_with_big_decimal = { 'amount' => big_decimal }
    json_string = hash_with_big_decimal.to_json

    # Should serialize as a number, not a quoted string
    assert_equal('{"amount":1.12345678912345678912345}', json_string)
    assert_not_match(/"1\.12345678912345678912345"/, json_string)
  end if defined?(::BigDecimal)

  def test_maintains_precision_through_full_round_trip_serialization
    big_decimal = BigDecimal('1.12345678912345678912345')
    hash_with_big_decimal = { 'amount' => big_decimal }

    # Original hash -> JSON string -> parsed hash
    json_string = hash_with_big_decimal.to_json
    parsed_back = JSON.parse(json_string)

    assert_instance_of(BigDecimal, parsed_back['amount'])
    assert_equal(big_decimal, parsed_back['amount'])
  end if defined?(::BigDecimal)

  def test_parses_string_bigdecimals_as_strings_not_bigdecimals
    json_with_string = '{"amount": "1.12345678912345678912345"}'
    parsed = JSON.parse(json_with_string)

    # String representations should remain as strings
    assert_instance_of(String, parsed['amount'])
    assert_equal('1.12345678912345678912345', parsed['amount'])
  end if defined?(::BigDecimal)

  def test_preserves_bigdecimals_in_nested_structures
    nested_hash = {
      'data' => {
        'price' => BigDecimal('99.999999999999999999'),
        'tax' => BigDecimal('0.08'),
      },
      'items' => [
        { 'cost' => BigDecimal('12.345') },
        { 'cost' => BigDecimal('67.890') },
      ],
    }

    json_string = nested_hash.to_json
    parsed_back = JSON.parse(json_string)

    assert_instance_of(BigDecimal, parsed_back.dig('data', 'price'))
    assert_kind_of(Numeric, parsed_back.dig('data', 'tax'))
    assert_kind_of(Numeric, parsed_back.dig('items', 0, 'cost'))
    assert_kind_of(Numeric, parsed_back.dig('items', 1, 'cost'))

    assert_equal(BigDecimal('99.999999999999999999'), parsed_back.dig('data', 'price'))
    assert_equal(BigDecimal('0.08'), parsed_back.dig('data', 'tax'))
    assert_equal(BigDecimal('12.345'), parsed_back.dig('items', 0, 'cost'))
    assert_equal(BigDecimal('67.890'), parsed_back.dig('items', 1, 'cost'))
  end if defined?(::BigDecimal)

  def test_handles_regular_floats_without_converting_to_bigdecimal
    hash_with_float = { 'value' => 1.23 }
    json_string = hash_with_float.to_json
    parsed_back = JSON.parse(json_string)

    # Regular floats should remain as floats (or be converted based on precision)
    assert_kind_of(Numeric, parsed_back['value'])
    assert_equal(1.23, parsed_back['value'])
  end if defined?(::BigDecimal)
end
