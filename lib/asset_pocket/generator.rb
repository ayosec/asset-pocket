
require 'asset_pocket/pocket'
require 'asset_pocket/source_filter'
require 'fileutils'

module AssetPocket
    class Generator
        attr_accessor :root_path

        def initialize
            @root_path = "."
            @pocket = nil
        end

        def parse_string(content)
            @pocket = Pocket.new(self)
            @pocket.parse_string content
        end

        def read_file(filename)
            File.read(File.join(@root_path, filename))
        end

        def run!
            @pocket.definitions.each do |definition|
                generated_filename = File.join(root_path, definition.filename)
                FileUtils.mkpath File.dirname(generated_filename)
                File.open(generated_filename, "w") do |generated_file|
                    generated_content = []
                    definition.content.map do |content|
                        case content[0]
                        when :pattern
                            generated_content <<
                                Dir["#{root_path}/#{content[1]}"].
                                    sort!.
                                    map! {|found_file| SourceFilter.filter found_file }

                        when :string
                            generated_content << content[1]

                        else
                            raise ArgumentError, "Unknown content type: #{content[0]}"
                        end
                    end

                    generated_content = generated_content.join(definition.separator)

                    if definition.use_compressor?
                        generated_content = definition.compressor.compress(generated_content)
                    end

                    generated_content = definition.post_process(generated_content)
                    generated_file.write(generated_content)
                end
            end

            true
        end

    end
end
