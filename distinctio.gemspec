require File.expand_path('../lib/distinctio/version.rb', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Andrew Gridnev,Arkadiy Zabazhanov"]
  gem.description   = %q{Model-agnostic diff framework.}
  gem.summary       = %q{}
  gem.homepage      = "https://github.com/puffer/distinctio"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "distinctio"
  gem.require_paths = ["lib"]
  gem.version       = Distinctio::VERSION

  gem.add_development_dependency 'rspec', '~> 2.11.0'
  gem.add_development_dependency 'diff_match_patch'
end