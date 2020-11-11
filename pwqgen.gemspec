# vim: set expandtab sw=2 ts=2:ft=ruby
require_relative 'lib/pwqgen/version'
Gem::Specification.new do |s|
  s.name = 'pwqgen'
  s.required_ruby_version = '>= 2.1'
  s.version = Pwqgen::VERSION
  s.summary = 'pwqgen'
  s.homepage = 'https://github.com/mhender/ruby-pwqgen'
  s.authors = ['Mark Henderson']
  s.description = 'pwqgen - ruby passphrase generator based on Openwall passwdqc'
  s.email = 'mch@mire.org'
  s.licenses = %w(BSD-3-Clause Nonstandard)
  s.files = %w(LICENSE README.markdown bin/pwqgen lib/pwqgen.rb)
  s.files.concat Dir.glob('lib/pwqgen/*.rb')
  s.require_paths = %w(lib)
  s.executables = %w(pwqgen)
  s.add_runtime_dependency('sysrandom', '~> 1')
  s.add_runtime_dependency('highline', '~> 2')
  s.add_development_dependency('rspec', '~> 3')
  s.add_development_dependency('rubocop', '~> 0')
  s.add_development_dependency('rake', '~> 12')
  s.add_development_dependency('bundler-geminabox')
end
