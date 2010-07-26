
require 'fileutils'
require 'nokogiri'

$: << File.expand_path("../../../lib/", __FILE__)
require 'asset_pocket/generator'

$temp_directory_count = 0
def make_temp_directory
    temp_dir = Pathname.new("/tmp/asset_pocket_test/t#$$/#{$temp_directory_count += 1}")
    temp_dir.mkpath
    temp_dir
end

class Pathname
    def rmdir_when_empty
        rmdir
        true
    rescue Errno::ENOTEMPTY
        false
    end
end

Before do
    @created_files = []
    @temp_dir = make_temp_directory

    AssetPocket::SourceFilter::Sass.default_options[:cache_location] = @temp_dir.join("sass-cache").to_s
end

After do
    @created_files.each do |filename|
        filename.delete
        filename.dirname.rmdir_when_empty
    end
end

