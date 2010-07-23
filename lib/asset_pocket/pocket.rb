
require 'asset_pocket/compressor'

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

        class Definitions
            attr_reader :content, :compressor, :filename, :pocket

            def initialize(pocket, filename)
                @pocket = pocket
                @content = []
                @filename = filename
                @compressor = nil
                @separator = ""
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
        end

        class JSDefinitions < Definitions
        end

        class SassDefinitions < Definitions
            def import(filename)
                @content << [ :string, "@import \"#{File.expand_path(filename, pocket.generator.root_path)}\";\n" ]
            end

            alias_method :use, :import

            def post_process(generated_content)
                SourceFilter::Sass.render("#{filename}.scss", generated_content)
            end
        end

    end
end
