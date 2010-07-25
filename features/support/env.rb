
require 'fileutils'

$: << File.expand_path("../../../lib/", __FILE__)
require 'asset_pocket'

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
