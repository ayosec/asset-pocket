require "rubygems"

spec = Gem::Specification.new do |gem|
   gem.name        = "asset-pocket"
   gem.version     = "0.2"
   gem.author      = "Ayose Cazorla"
   gem.email       = "setepo@gmail.com"
   gem.homepage    = "http://github.com/setepo/asset_pocket"
   gem.platform    = Gem::Platform::RUBY
   gem.summary     = "Manages assets in a versatile way"
   gem.description = "Using a config file (pocket) you can create multiple kind of assets groups"
   gem.has_rdoc    = false
   gem.files       = Dir["features/**/*"] + Dir["lib/**/*"] + Dir["rails/*"]
   gem.require_path = "lib"
end

if $0 == __FILE__
   Gem.manage_gems
   Gem::Builder.new(spec).build
end
