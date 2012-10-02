require File.expand_path('../lib/diff/version.rb', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Andrew Gridnev"]
  gem.email         = ["andrew.gridnev@gmail.com"]
  gem.description   = %q{}
  gem.summary       = %q{}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "cms_engine"
  gem.require_paths = ["lib"]
  gem.version       = Diff::VERSION

  gem.add_development_dependency 'rspec', '~> 2.11.0'
  gem.add_development_dependency 'diff_match_patch'
end