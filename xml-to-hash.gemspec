# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'xml/to/hash'

Gem::Specification.new do |spec|
  spec.name = 'xml-to-hash'
  spec.version = Xml::To::Hash::VERSION
  spec.authors = ['Maarten Trompper']
  spec.email = ['maartentrompper@gmail.com']

  spec.required_ruby_version = '>= 1.9.2'

  spec.summary = %q{Transparently transform XML documents to Ruby hashes (and JSON, and beyond)}
  spec.description = %q{This gem adds a `to_hash` method to Nokogiri XML nodes into a Ruby hash. In the resulting hash, all keys are constants.

This gem also picks up attributes, processing instructions and doctype declarations. The resulting Hash is wordy, but complete.

As an added bonus, we include line numbers where possible.}
  spec.homepage = 'https://github.com/digitalheir/ruby-xml-to-hash'
  spec.license = 'MIT'

  # # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # # delete this section to allow pushing this gem to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = "http://mygemserver.com"
  # else
  #   raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  # end

  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']


  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 2.4'

  spec.add_runtime_dependency 'nokogiri', '~> 1', '>= 1.6'
end
