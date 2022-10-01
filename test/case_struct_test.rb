require 'minitest/autorun'
require_relative '../lib/case_struct'

class CaseStructTest < Minitest::Test
  def exercises(cases:, values_expected:)
    @examples.zip(values_expected).each do |example, expected|
      method, *params = case expected
                       when NilClass
                         [:assert_nil, cases[example]]
                       else
                         [:assert_equal, expected, cases[example]]
                       end
      send(method, *params)
    end

    assert_equal(@examples.map(&cases), values_expected)
  end

  
  def setup
    base_hash = {
      (1..5) => :low,
      (6..10) => :moderate,
      (11..) => :high,
    }.freeze

    @examples = [-1, 3, 8, 100]
    
    @hash = base_hash.dup.extend(CaseStruct)
    
    @hash_with_default_value = base_hash.dup
                                        .tap { _1.default = :unknown }
                                        .extend(CaseStruct)

    @hash_with_default_proc = base_hash.dup
                                       .tap { _1.default_proc = proc{ :unknown } }
                                       .extend(CaseStruct)

    @array = base_hash.to_a.extend(CaseStruct)

    @array_with_default_entry = @array.dup
                                      .tap { _1 << [Object, :unknown] }
                                      .extend(CaseStruct)

    @array_with_default_and_unreachable_entries = @array.dup
                                                        .then { _1 + [[Object, :unknown],
                                                                      [(-5..-1), :unreachable]] }
                                                        .extend(CaseStruct)
  end

  
  def test_hash
    exercises(cases: @hash,
              values_expected: [nil, :low, :moderate, :high])
  end

  def test_hash_with_default_value
    exercises(cases: @hash_with_default_value,
              values_expected: [:unknown, :low, :moderate, :high])
  end

  def test_hash_with_default_proc
    exercises(cases: @hash_with_default_proc,
              values_expected: [:unknown, :low, :moderate, :high])
  end

  def test_array
    exercises(cases: @array,
              values_expected: [nil, :low, :moderate, :high])
  end

  def test_array_with_default_entry
    exercises(cases: @array_with_default_entry,
              values_expected: [:unknown, :low, :moderate, :high])
  end

  def test_array_with_default_and_unreachable_entries
    exercises(cases: @array_with_default_and_unreachable_entries,
              values_expected: [:unknown, :low, :moderate, :high])
  end
end
