# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "middleman-cordova"
  s.version     = "0.1.1"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Patryk Ptasiński"]
  s.email       = ["patryk@ipepe.pl"]
  s.homepage    = "https://github.com/ipepe/middleman-cordova"
  s.summary     = %q{Middleman integrated with Cordova}
  s.description = %q{Middleman integrated with Cordova to build hybrid apps}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  # The version of middleman-core your extension depends on
  s.add_runtime_dependency("middleman-core", [">= 4.2.1"])
  s.add_runtime_dependency("nokogiri", ['1.10.3'])

  # Additional dependencies
  # s.add_runtime_dependency("gem-name", "gem-version")
end
