
require 'asset_pocket/pocket'
require 'fileutils'

module AssetPocket
    class Generator
        attr_accessor :root_path

        def initialize
            @root_path = "."
            @pocket = nil
        end

        def parse_string(content)
            @pocket = AssetPocket::Pocket.new(self)
            @pocket.parse_string content
        end

        def run!
            @pocket.definitions.each do |definition|
                generated_filename = File.join(root_path, definition.filename)
                FileUtils.mkpath File.dirname(generated_filename)
                File.open(generated_filename, "w") do |generated_file|
                    content = definition.files.flatten.map do |pattern|
                        Dir["#{root_path}/#{pattern}"].sort!.map! do |found_file|
                            File.read(found_file)
                        end
                    end.flatten!.join(definition.separator)

                    if definition.use_compressor?
                        content = definition.compressor.compress(content)
                    end

                    generated_file.write(content)
                end
            end

            true
        end

    end
end
