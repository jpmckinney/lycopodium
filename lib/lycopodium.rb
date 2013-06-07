require 'set'

class Lycopodium
  class Error < StandardError; end
  class Collision < Error; end

  def initialize(set)
    @set = set
  end

  def test(meth)
    hashes = {}
    counts = Hash.new(0)

    @set.each do |item|
      hashes[item] = meth.call(item) unless hashes.key?(item)
      counts[hashes[item]] += 1
    end

    collisions = counts.select do |_,count|
      count > 1
    end.map do |hash,_|
      hash
    end

    unless collisions.empty?
      message = []
      collisions.each do |value|
        items = hashes.select do |_,hash|
          hash == value
        end.map do |item,_|
          item
        end
        message << %(#{items.map{|item| %("#{item}")} * ", "} => "#{value}")
      end
      raise Collision, message * "\n"
    end

    hashes
  end
end
