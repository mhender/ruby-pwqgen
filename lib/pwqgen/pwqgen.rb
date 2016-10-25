# vim: set expandtab sw=2 ts=2:ft=ruby
require 'sysrandom'

# Ruby implementation of Openwall passwdqc
module Pwqgen
  # default separators
  SEPARATORS = '-_!$&*+=23456789'.each_char.to_a # from passwdqc - passwdqc_random.c

  # numeric separators
  NUMERIC_SEPARATORS = '23456789'.each_char.to_a # less entropy, but for sites that cannot use chatacters like _-, etc.

  class << self
    # for calculating base 2 log without any worry about floating point errors
    LOG2_TABLE = {
      1 => 0,
      2 => 1,
      4 => 2,
      8 => 3,
      16 => 4,
      32 => 5,
      64 => 6,
      128 => 7,
      256 => 8,
      512 => 9,
      1024 => 10,
      2048 => 11,
      4096 => 12
    }.freeze

    # Pwqgen.pwqgen - generate a random passphrase using the pwqgen algorithm
    #
    # Arguments:
    #   n_words: (Integer)
    #   random_generator: (Proc) - Proc or method reference - this should take one argument, n, and return n random bytes
    #     as a String of length n. Default is to use Sysrandom.random_bytes
    #   separators: (String) - separators for use between words. Default is Pwqgen::SEPARATORS. Array of one character strings
    #   random_capitalize: (Boolean) - whether or not to "randomly" capitalize words. Default is true.
    #
    # Examples:
    #   require 'pwqgen'
    #   require 'securerandom'  # only for the second and third examples
    #
    #   # Five words. Default behaviour
    #   puts Pwqgen.pwqgen(n_words: 5)
    #
    #   # use Securerandom instead of Sysrandom and with custom separators
    #   puts Pwqgen.pwqgen(n_words: 5,
    #   random_generator: SecureRandom.method(:random_bytes),
    #   random_capitalize: false,
    #   separators: %w(2 3 4 |)
    #   )
    #   # OR
    #   puts Pwqgen.pwqgen(n_words: 5,
    #   random_generator: proc { |x| SecureRandom.random_bytes(x) },
    #   random_capitalize: false,
    #   separators: %w(2 3 4 |)
    #   )
    #
    #   # produces "adam-adam-adam-adam" as the random generator always returns 0
    #   puts Pwqgen.pwqgen(n_words: 4, random_generator: Proc.new {|x| "\000" * x }})
    def pwqgen(
        n_words:,
        random_generator:       proc { |x| Sysrandom.random_bytes(x) },
        separators:             SEPARATORS,
        random_capitalize:      true
    )
      # validate arguments
      raise ArgumentError, "n_words must be an integer: #{n_words.inspect}" unless n_words.is_a? Integer
      raise ArgumentError, "n_words must be a positive integer: #{n_words.inspect}" if n_words < 1
      raise ArgumentError, "invalid random_generator: #{random_generator.inspect}" unless random_generator.respond_to? :call
      raise ArgumentError, "separators must be Array of length 2**n n<=12, of one characters strings: #{separators.inspect}" \
        unless (separators.is_a? Array) && separators.inject(true) { |a, e| a && (e.is_a? String) && e.length == 1 } \
        && LOG2_TABLE[separators.length]

      random_separators = Array.new(n_words - 1) { random_separator(random_generator: random_generator, separators: separators) }
      random_words = Array.new(n_words) { random_word(random_generator: random_generator, random_capitalize: random_capitalize) }

      # interleave random_words and random_separators. Relies on nil.to_s is empty string
      random_words.inject('') do |a, e|
        a + e + random_separators.shift.to_s
      end
    end

    private

    # Get n_bits bits from the random generator. This squanders some randomness,
    # since it gets the required number of bytes and throws away bits that
    # are not needed. Returns an Integer between 0 and 2**n_bits - 1.
    # Arguments:
    #   random_generator: (Proc) Proc or method reference for random_bytes
    #   n_bits: (Integer)
    def random_bits(random_generator:, n_bits:)
      bits = 0
      random_generator.call(((n_bits - 1) / 8) + 1).unpack('C*').each_with_index { |byte, i| bits |= byte << (8 * i) }
      bits & ((1 << n_bits) - 1) # throw away the bits we do not need
    end

    # generate a single word "randomly" chosen from WORDSET
    # with the option to capitalize "randomly"
    def random_word(random_generator:, random_capitalize: true) # :nodoc:
      random_word = WORDSET[random_bits(random_generator: random_generator, n_bits: LOG2_TABLE[WORDSET.length])].dup
      random_word.capitalize! if random_capitalize && (random_bits(random_generator: random_generator, n_bits: 1) == 1)
      random_word
    end

    # generate a separator "randomly" chosen from separators
    def random_separator(random_generator:, separators:)
      separators[random_bits(random_generator: random_generator, n_bits: LOG2_TABLE[separators.length])]
    end
  end
end
