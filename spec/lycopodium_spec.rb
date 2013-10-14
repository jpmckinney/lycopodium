require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Lycopodium do
  describe '#initialize' do
    it 'should use an identify function by default' do
      set = Lycopodium.new([])
      set.function.call(1).should == 1
    end

    it 'should accept a function as an argument' do
      set = Lycopodium.new([], lambda{|value| value * 2})
      set.function.call(1).should == 2
    end
  end

  let :collisions do
    Lycopodium.new(['foo', 'f o o', 'bar'], lambda{|string| string.gsub(/\p{Space}/, '')})
  end

  let :no_collisions do
    Lycopodium.new(['foo', 'f o o', 'bar'], lambda{|string| string.upcase})
  end

  describe '#reject_collisions' do
    it 'should remove all members of the set that collide after transformation' do
      collisions.reject_collisions.should == ['bar']
    end
  end

  describe '#value_to_fingerprint' do
    it 'should return a mapping from the original to the transformed value' do
      no_collisions.value_to_fingerprint.should == {'foo' => 'FOO', 'f o o' => 'F O O', 'bar' => 'BAR'}
    end

    it 'should raise an error if the method creates collisions between members of the set' do
      expect{collisions.value_to_fingerprint}.to raise_error(Lycopodium::Collision, %("foo", "f o o" => "foo"))
    end
  end
end
