require "set"

class Lycopodium < Array
  class Error < StandardError; end
  class Collision < Error; end
  class RaggedRow < Error; end

  attr_accessor :function

  # Returns the shortest unique key in the data table.
  #
  # @param [Array<Array>] a data table as a two-dimensional array
  # @return [Array,nil] the shortest unique key, or nil if none found
  # @raise [RaggedRow] if the rows in the data table are not of equal length
  def self.unique_key(table)
    columns_size = table.first.size
    table.each do |row|
      unless row.size == columns_size
        raise RaggedRow, row.inspect
      end
    end

    indices = (0...columns_size).to_a
    1.upto(columns_size) do |k|
      indices.combination(k) do |combination|
        if unique_key?(table, combination)
          return combination
        end
      end
    end

    nil
  end

  # @param [Array] set a set of values
  # @param [Proc] function a method that transforms a value
  def initialize(set, function = lambda{|value| value})
    replace(set)
    @function = function
  end

  # Removes all members of the set that collide after transformation.
  #
  # @return [Array] the members of the set without collisions
  def reject_collisions
    hashes, collisions = hashes_and_collisions

    items = []
    hashes.each do |item,hash|
      unless collisions.include?(hash)
        items << item
      end
    end
    self.class.new(items, function)
  end

  # Returns a mapping from the original to the transformed value.
  #
  # @return [Hash] a mapping from the original to the transformed value
  # @raise [Collision] if the method creates collisions between members of the set
  def value_to_fingerprint
    hashes, collisions = hashes_and_collisions

    unless collisions.empty?
      message = []
      collisions.each do |collision|
        items = hashes.select do |_,hash|
          hash == collision
        end.map do |item,_|
          item
        end
        message << %(#{items.map(&:inspect) * ", "} => "#{collision}")
      end
      raise Collision, message * "\n"
    end

    hashes
  end

private

  def self.unique_key?(table, combination)
    set = Set.new
    table.each_with_index do |row,index|
      set.add(row.values_at(*combination))
      if set.size <= index
        return false
      end
    end
    true
  end

  def hashes_and_collisions
    collisions = Set.new

    hashes = {}
    counts = {}

    each do |item|
      unless hashes.key?(item)
        hashes[item] = function.call(item)
      end
      if counts.key?(hashes[item])
        collisions << hashes[item]
      else
        counts[hashes[item]] = 1
      end
    end

    [hashes, collisions]
  end
end
