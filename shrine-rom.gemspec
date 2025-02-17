Gem::Specification.new do |gem|
  gem.name          = "shrine-rom"
  gem.version       = "0.1.0"

  gem.required_ruby_version = ">= 2.3"

  gem.summary      = "Provides rom-rb integration for Shrine."
  gem.homepage     = "https://github.com/shrinerb/shrine-rom"
  gem.authors      = ["Janko Marohnić", "Ahmad Musaffa"]
  gem.email        = ["janko.marohnic@gmail.com", "musaffa_csemm@yahoo.com"]
  gem.license      = "MIT"

  gem.files        = Dir["README.md", "LICENSE.txt", "lib/**/*.rb", "*.gemspec"]
  gem.require_path = "lib"

  gem.add_dependency "shrine", "~> 2.9"
  gem.add_dependency "rom", "3.3.3"
end
