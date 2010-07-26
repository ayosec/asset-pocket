
namespace :pocket do

    desc "Update the pocket using AssetPocket"
    task :update => :environment do
        require 'asset_pocket/generator'
        generator = AssetPocket::Generator.new
        generator.root_path = Rails.root
        generator.parse_string Rails.root.join("config/pocket.rb").read
        generator.run!
    end
end
