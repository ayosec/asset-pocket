
require 'asset_pocket/pocket'
require 'asset_pocket/source_filter'
require 'fileutils'
require 'pathname'

module AssetPocket
    class Generator
        attr_reader :root_path

        def initialize
            self.root_path = "."
            @pocket = nil
        end

        def root_path=(path)
            @root_path = Pathname.new(path.to_s)
        end

        def parse_string(content)
            @pocket = Pocket.new(self)
            @pocket.parse_string content
        end

        def read_file(filename)
            root_path.join(filename).read
        end

        def run!
            @pocket.definitions.each do |definition|
                send "process_#{definition.process}", definition
            end
            true
        end

        def process_create_file(definition)
            generated_filename = root_path.join(definition.filename)
            FileUtils.mkpath File.dirname(generated_filename)
            File.open(generated_filename, "w") do |generated_file|
                generated_content = []
                definition.content.each do |content|
                    case content[0]
                    when :pattern
                        generated_content.concat(
                            Dir[root_path.join(content[1])].
                                sort!.
                                map! {|found_file| SourceFilter.filter found_file })

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

        def process_copy_files(definition)
            base = Pathname.new(File.expand_path(definition.base, root_path))
            dest_dir = root_path.join(definition.filename)
            dest_dir.mkpath

            definition.content.each do |content|
                case content[0]
                when :pattern
                    Dir[root_path.join(content[1])].each do |source_file|
                        source_file = Pathname.new(source_file)

                        # Only work with regular file
                        next unless source_file.file?

                        dest_file = dest_dir.join(source_file.relative_path_from(base))

                        if dest_file.exist?
                            # Compare it using timestamps and size
                            if source_file.size == dest_file.size and source_file.mtime == dest_file.mtime
                                next
                            end

                            # Remove it, since we have to recreate
                            dest_file.delete
                        end

                        # Try to create a hard link (Unix on same mount points).
                        # If it fails, copy it
                        dest_file.dirname.mkpath
                        begin
                            dest_file.make_link source_file
                        rescue Exception => e
                            dest_file.open("w") {|f| f.write source_file.read }
                        end
                    end
                end
            end
        end
    end
end
