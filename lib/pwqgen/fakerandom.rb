# vim: set expandtab sw=2 ts=2:ft=ruby

require 'openssl'

module Pwqgen
  # Pwqgen::FakeRandom is a keyed, not really random, number generator that uses an HMAC.
  # it intentionally mimics the random_bytes method in SecureRandom/Sysrandom.
  # The high number of iterations is an attempt to make brute forcing the
  # key more expensive given the string and some pwqgen output.
  # The idea of using a HMAC based keyed generator was inspired by the pwdhash algorithm.
  #
  # Example:
  #   require 'pwqgen'
  #   n = Pwqgen::FakeRandom.new('bob', 'terribly secret key').method(:random_bytes)
  #   # returns a string with 256 random bytes
  #   puts n.call(256)
  #   # use the FakeRandom object to generate a not really random passphrase
  #   puts Pwqgen.pwqgen(n_words: 5, random_generator: n)
  #   # OR
  #   n1 = Pwqgen::FakeRandom.new('bob', 'even more terribly secret key')
  #   puts Pwqgen.pwqgen(n_words: 4, random_generator: proc { |x| n1.random_bytes(x) })
  class FakeRandom
    # number of iterations for the HMAC.
    HMAC_ITERATIONS = 100_000

    # Initialize a new FakeRandom object
    #
    # Arguments:
    #   string: (String)
    #   key: (String)
    def initialize(string, key)
      @key = key.encode(Encoding::ASCII_8BIT)
      @dstr = string.encode(Encoding::ASCII_8BIT)
      @digest = ::OpenSSL::Digest.new('sha512').freeze
      @results = []
    end

    # Generate n random bytes.
    # This mimics the interface of Sysrandom.random_bytes and SecureRandom.random_bytes
    # Returns a string of length n
    # Arguments:
    #   n: (Integer)
    def random_bytes(n = 16)
      generate_bytes while @results.length < n
      # now @results.length >= n
      bytes = @results[0..(n - 1)]
      @results = @results[n..-1]
      bytes.pack('C*')
    end

    private

    # Generate (more) bytes of quasi-random data.
    def generate_bytes
      HMAC_ITERATIONS.times { @dstr = ::OpenSSL::HMAC.digest(@digest, @key, @dstr) }
      @results += @dstr.unpack('C*')

      # Generate new @key and @dstr for next call (if it ever happens)
      # This is inspired by HMAC-DRBG
      @key = ::OpenSSL::HMAC.digest(@digest, @key, @dstr + "\000")
      @dstr = ::OpenSSL::HMAC.digest(@digest, @key, @dstr)
    end
  end
end
