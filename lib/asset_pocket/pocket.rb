
require 'asset_pocket/compressor'
require 'asset_pocket/css_sprites'

module AssetPocket
    class Pocket

        attr_reader :definitions, :generator

        def initialize(generator)
            @generator = generator
            @definitions = []
        end

        def parse_string(content)
            instance_eval content
        end

        def compressor(name, options = {})
            AssetPocket::Compressor.parse name, options
        end

        def sass(option = {}, &block)
            case option
            when Hash
                SourceFilter::Sass.default_options.merge! option
            when String
                defs = SassDefinitions.new(self, option)
                defs.instance_eval(&block)
                definitions << defs
            else
                raise ArgumentError, "Unknown argument type: #{options.class}"
            end
        end

        def css(filename, &block)
            defs = CSSDefinitions.new(self, filename)
            defs.instance_eval(&block)
            definitions << defs
        end

        def js(filename, &block)
            defs = JSDefinitions.new(self, filename)
            defs.instance_eval(&block)
            definitions << defs
        end

        def files(dirname, &block)
            defs = FilesDefinitions.new(self, dirname)
            defs.instance_eval(&block)
            definitions << defs
        end

        class Definitions
            attr_reader :content, :compressor, :filename, :pocket

            def initialize(pocket, filename)
                @pocket = pocket
                @content = []
                @filename = filename
                @compressor = nil
                @separator = ""
            end

            def full_filename
                pocket.generator.root_path.join filename
            end

            def process
                :create_file
            end

            def use_compressor?
                @compressor
            end

            def use(pattern)
                @content << [ :pattern, pattern ]
            end

            def compress(name, options = {})
                @compressor = AssetPocket::Compressor.parse name, options
            end

            def separator(new_value = nil)
                @separator = new_value unless new_value.nil?
                @separator
            end

            def post_process(generated_content)
                generated_content
            end

        end

        class CSSDefinitions < Definitions

            def sprite(name, &block)
                @current_sprite = SpriteDefition.new(name, self)
                block.call
                @current_sprite.generate!
            ensure
                @current_sprite = nil
            end

            def layout(value)
                ensure_sprite!
                @current_sprite.layout = value
            end

            def images_location(value)
                ensure_sprite!
                @current_sprite.images_location = value
            end

            def use(pattern)
                if @current_sprite
                    @current_sprite.use pattern
                else
                    super
                end
            end

        private
            def ensure_sprite!
                raise NameError, "this macro has to be used in a sprite block" if @current_sprite.nil?
            end
        end

        class JSDefinitions < Definitions
        end

        class SassDefinitions < Definitions
            def import(filename)
                @content << [ :string, "@import \"#{File.expand_path(filename, pocket.generator.root_path)}\";\n" ]
            end

            def post_process(generated_content)
                SourceFilter::Sass.render("#{filename}.scss", generated_content)
            end

            undef_method :use
        end

        class FilesDefinitions < Definitions
            def process
                :copy_files
            end

            def base(value = nil)
                @base = value if value
                @base || "."
            end

            undef_method :separator
            undef_method :compress
        end

    end
end
