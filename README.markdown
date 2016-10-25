## Overview
This is an implementation of the pwqgen "random" password generation
algorithm. It is loosely derived from the C version in passwdqc.
See see http://www.openwall.com/passwdqc/

This is not a particularly well polished piece software. I wrote
it because I needed it and am sharing it because it might be useful
to others.

pwqgen run with the defaults give 64 bits of entropy sourced 
from Sysrandom (see https://rubygems.org/gems/sysrandom/versions/1.0.3)

## Command Line Tool

pwqgen has the following options:

    -k, --key STRING                 use hmac generator. key from /home/xyzzy/.skey
    -p, --prompt-key STRING          use hmac generator. key from prompt
    -n, --numeric-separators         use restricted separator list - numbers only
    -s, --never-capitalize           never capitalize
    -l, --length LENGTH              length of passphrase in words (minimum 3)
    -b, --bits LENGTH                approximate desired entropy (overrides -l)
    -v, --version                    send version number to stdout
    -h, --help                       Show this message

## HMAC quasi-random number generation

This -k option and -p options are experimental and need some
explanation. They use key material from ~/.skey or a prompted key
and generate a predictable quasi-random stream based on the string
passed to -k/-p. If you use this option, you should attempt to keep
the key material in ~/.skey or typed into the prompt secret. It
uses 100,000 iterations of SHA512 HMAC to do this (see class
Pwqgen::FakeRandom in lib/pwqgen.rb)

You can also specify the environment variable SKEYFILE to override
the default key file location of ~/.skey

With this appraoch "pwqgen -k bob" will always give the same string.
You could then use pwqgen instead of a password safe by generating
predictable random-looking passwords. I'm not necessarily recommending
this.

e.g. "pwqgen -k somesite.com" or "pwqgen -p somesite.com" could be used to
generate the password for somesite.com

## Requirements
* sysrandom gem (you can change the code to use SecureRandom, but this is probably not a great idea)
* highline gem (for -p option)
* ruby version >= 2.1

## TODO
* man page
* validate the FakeRandom approach to keyed quasi-random generation. It is probably fine as a simple HMAC as long as one doesn't use more than 512 bits.

## Build 

Building the gem is standard:

        gem build pwqgen.gemspec

Then you can install it with 

        gem install

or use the Rakefile/Gemfile

        gem install bundler
        bundle install
        bundle exec rake

## Usage

Other than the command line interface, you can also call this functionality by calling Pwqgen.pwqgen.

There are four named parameters.

n_words - Integer. Number of words used. This is required.

random_generator - Proc or method reference - this should yield a
string with n bytes when n is passed in. Default is to use
Sysrandom.random_bytes

separators - separators for use between words. Default is Pwqgen::SEPARATORS. 
Must be an array of one character strings of length = 2**n for some n between 0 and 12

random_capitalize - Boolean - whether or not to "randomly" capitalize words. Default is true.

## Examples

			require 'pwqgen'
			require 'securerandom'  # only for the second and third

			# Five words. Default behaviour
			puts Pwqgen.pwqgen(n_words: 5)

			# use Securerandom instead of Sysrandom and with custom separators
			puts Pwqgen.pwqgen(n_words: 5, 
			random_generator: SecureRandom.method(:random_bytes),
			random_capitalize: false,
			separators: %w(2 3 4 |)
			)
			# OR
			puts Pwqgen.pwqgen(n_words: 5,
			random_generator: proc { |x| SecureRandom.random_bytes(x) },
			random_capitalize: false,
			separators: %w(2 3 4 |)
			)

			# produces "adam-adam-adam-adam" as the random generator always returns 0
			puts Pwqgen.pwqgen(n_words: 4, random_generator: proc { |x| "\000" * x })


