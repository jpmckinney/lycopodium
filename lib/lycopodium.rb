require "set"

class Lycopodium < Array
  class Error < StandardError; end
  class Collision < Error; end

  attr_accessor :function

  # @param [Array] set a set of values
  # @param [Proc] function a method that transforms a value
  def initialize(set, function = lambda{|value| value})
    replace(set)
    self.function = function
  end

  # Removes all members of the set that collide after transformation.
  #
  # @return [Array] the members of the set without collisions
  def reject_collisions
    hashes, collisions = hashes_and_collisions

    items = hashes.reject do |_,hash|
      collisions.include?(hash)
    end.map do |item,_|
      item
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
