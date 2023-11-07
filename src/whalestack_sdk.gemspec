# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'whalestack_sdk/config'

Gem::Specification.new do |s|
  s.name        = 'whalestack_sdk'
  s.version     = WhalestackSDK::CLIENT_VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Whalestack LLC']
  s.email       = ['service@whalestack.com']
  s.homepage    = 'https://www.whalestack.com'
  s.summary     = %q{Whalestack SDK. Programmatically accept and settle payments in digital currencies.}
  s.licenses    = ['Apache-2.0']
  s.required_ruby_version = '>= 2.0.0'

  s.add_runtime_dependency 'rest-client', '~> 2.1', '>= 2.1.0'
  s.add_runtime_dependency 'json', '~> 2.3', '>= 2.3.0'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
end