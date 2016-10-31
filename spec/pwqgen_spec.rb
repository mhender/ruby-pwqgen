# vim: set expandtab sw=2 ts=2:ft=ruby
require 'pwqgen'

describe Pwqgen do
  describe '.pwqgen' do
    context 'fixed generator 0' do
      it 'returns adam-adam-adam-adam with 4 words - defaults' do
        expect(Pwqgen.pwqgen(n_words: 4, random_generator: proc { |x| "\000" * x })).to eql('adam-adam-adam-adam')
      end
      it 'returns adam2adam2adam2adam with 4 words - numeric separators' do
        expect(Pwqgen.pwqgen(n_words: 4, random_generator: proc { |x| "\000" * x }, separators: Pwqgen::NUMERIC_SEPARATORS)).to \
          eql('adam2adam2adam2adam')
      end
    end

    context 'fixed generator 1' do
      it 'returns Afghan_Afghan_Afghan with 3 words - defaults' do
        expect(Pwqgen.pwqgen(n_words: 3, random_generator: proc { |x| "\001" * x })).to eql('Action_Action_Action')
      end

      it 'returns afghan_afghan_afghan_afghan with 4 words - random_capitalize: false' do
        expect(Pwqgen.pwqgen(n_words: 4, random_generator: proc { |x| "\001" * x }, random_capitalize: false)).to \
          eql('action_action_action_action')
      end

      it 'returns afghan3afghan3afghan with 4 words - random_capitalize: false and numeric separators' do
        word = Pwqgen.pwqgen(
          n_words: 4,
          random_generator: proc { |x| "\001" * x },
          random_capitalize: false,
          separators: Pwqgen::NUMERIC_SEPARATORS
        )
        expect(word).to eql('action3action3action3action')
      end
    end

    context 'fixed generator with 0x01, 0xff' do
      it 'returns Uproar_Uproar_Uproar_Uproar with 4 words' do
        word = Pwqgen.pwqgen(
          n_words: 4,
          random_generator: proc { |x| "\x01\xFF"[0..x] },
          random_capitalize: true
        )
        expect(word).to eql('Uproar_Uproar_Uproar_Uproar')
      end
    end

    context 'Securerandom generator NUMERIC_SEPARATORS' do
      it 'contains 4 words separated by numeric separators when NUMERIC_SEPARATORS is specified' do
        expect(Pwqgen.pwqgen(n_words: 4, separators: Pwqgen::NUMERIC_SEPARATORS)).to \
          match('([A-Za-z][a-z]{2,}\d){3}[A-Za-z][a-z]{2,}')
      end
    end

    context 'Securerandom generator' do
      it 'contains 5 words separated by separators when SEPARATORS is specified' do
        expect(Pwqgen.pwqgen(n_words: 5, separators: Pwqgen::NUMERIC_SEPARATORS)).to \
          match('([A-Za-z][a-z]{2,}[-_!$&*+=23456789]){4}[A-Za-z][a-z]{2,}')
      end
    end

    context 'pwqgen with FakeRandom generator' do
      it 'returns cider$handle9blood!Dinghy5vain' do
        expect(Pwqgen.pwqgen(n_words: 5, random_generator: Pwqgen::FakeRandom.new('string', 'very secret key')\
          .method(:random_bytes))).to eql('cider$handle9blood!Dinghy5vain')
      end
    end

    context 'exception handling' do
      it 'raises ArgumentError when the number of separators is not a power of 2' do
        expect { Pwqgen.pwqgen(n_words: 4, separators: %w(1 2 3)) }.to raise_error(ArgumentError)
      end
      it 'raises ArgumentError when separators is not an array' do
        expect { Pwqgen.pwqgen(n_words: 4, separators: '123') }.to raise_error(ArgumentError)
      end
      it 'raises ArgumentError when separators is an array with a non-string element' do
        expect { Pwqgen.pwqgen(n_words: 4, separators: [1, 2, '3']) }.to raise_error(ArgumentError)
      end
      it 'raises ArgumentError when the random_generator does not respond to call' do
        expect { Pwqgen.pwqgen(n_words: 4, random_generator: 42) }.to raise_error(ArgumentError)
      end
    end
  end
end
