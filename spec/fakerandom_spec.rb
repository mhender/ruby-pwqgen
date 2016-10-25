# vim: set expandtab sw=2 ts=2:ft=ruby
require 'pwqgen'

describe Pwqgen::FakeRandom do
  describe '.random_bytes' do
    context 'predictable values' do
      it 'returns "\xCB" with specific keys and 1 as parameter' do
        expect(Pwqgen::FakeRandom.new('123', '456').random_bytes(1).unpack('C*').first).to eql(203)
      end
      it 'returns "\xCB\x8A" with specific keys and 2 as a parameter' do
        expect(Pwqgen::FakeRandom.new('123', '456').random_bytes(2).unpack('C*')).to eql([203, 138])
      end
      (0..16).each do |len|
        it "returns #{len} bytes when called with #{len} as parameter" do
          expect(Pwqgen::FakeRandom.new('123', '456').random_bytes(len).length).to eql(len)
        end
      end
      it 'follows a reasonable bit distribution pattern and can generate lots of random bits (1)' do
        n = Pwqgen::FakeRandom.new('123', '456')
        sum = 0
        512.times do
          # add the number of 1s in the binary representation of n to sum
          sum += ('%08b' % n.random_bytes(1).unpack('C*').first).scan(/1/).length
        end
        expect(sum).to eql(2009)
      end
      it 'follows a reasonable bit distribution pattern and can generate lots of random bits (2)' do
        n = Pwqgen::FakeRandom.new('1234', '4567')
        sum = 0
        512.times do
          # add the number of 1s in the binary representation of n to sum
          sum += ('%08b' % n.random_bytes(1).unpack('C*').first).scan(/1/).length
        end
        expect(sum).to eql(2089)
      end
    end
  end
end
