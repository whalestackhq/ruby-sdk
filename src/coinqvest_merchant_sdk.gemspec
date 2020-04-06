# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'coinqvest_merchant_sdk/config'

Gem::Specification.new do |s|
  s.name        = 'coinqvest_merchant_sdk'
  s.version     = CoinqvestMerchantSDK::CLIENT_VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['COINQVEST Ltd.']
  s.email       = ['service@coinqvest.com']
  s.homepage    = 'http://www.coinqvest.com'
  s.summary     = %q{Ruby Merchant SDK for COINQVEST. Programmatically accept and settle payments in digital currencies.}
  s.licenses    = ['Apache-2.0']
  s.required_ruby_version = '>= 2.0.0'

  s.add_runtime_dependency 'rest-client', '~> 2.1', '>= 2.1.0'
  s.add_runtime_dependency 'json', '~> 1.8', '>= 1.8.3'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
end