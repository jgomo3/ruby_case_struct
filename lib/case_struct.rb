# CaseStruct
#
# Enable using Hash like structures
# as an alternative to case/when expressions.
#
# This gives the posibility to construct such expressions
# dynamically. Kind of a Rule Engine.
#
# It is intended to be used by extending the structure
# with this module.
#
# ```ruby
# cases = {
#   (1..5) => :low,
#   (6..10) => :moderate,
#   (11..) => :high,
# }.extend(CaseStruct)
#
# cases[3] # => :low
# cases[8] # => :moderate
# cases[100] # => :high
# ```
#
# If used as a proc, it will still behave as the case/when expression:
#
# ```ruby
# [3, 8, 100].map(&cases)
# # => [:low, :moderate, :high]
# ```
#
# Defatults to `nil` unless the extended structure defined or a
# `default_proc` or a `default` value.
#
# This supports directly the behaviour of Hashes.
#
# ```ruby
# cases = {
#   (1..5) => :low,
#   (6..10) => :moderate,
#   (11..) => :high,
# }.tap { _1.default = :unknown }
#  .extend(CaseStructure)
#
# [-1, 3, 8, 100].map(&cases)
# # => [:unkown, :low, :moderate, :high]
# ```
#
# Alternatively, define an entry in the structure that is always
# true. This is what you can do in case your structure is not a Hash, but an Array of duples.
#
# ```ruby
# cases [
#   [(1..5), :low],
#   [(6..10), :moderate],
#   [(11..), :high],
#   [Object, :unkown ], # Always true
#   [(-5..-1), :never_reached]
# ]
#
# [-1, 3, 8, 100].map(&cases)
# # => [:unkown, :low, :moderate, :high]
# ```
#
# Notice the `:never_reached` symbol. Everything will be captured by the previous
# always true entry.
#
module CaseStruct
  def [](key)
    find(_case_struct_default) { |k, _| k === key }&.last
  end

  def to_proc
    proc { self[_1] }
  end

  private
  def _case_struct_default
    proc do
      value = case
              when respond_to?(:default_proc) && !default_proc.nil?
                default_proc.call
              when respond_to?(:default) && !default.nil?
                default
              end
      [nil, value]
    end
  end
end
