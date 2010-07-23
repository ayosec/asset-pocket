
module AssetPocket
    class Pocket

        attr_reader :definitions

        def initialize(generator)
            @generator = generator
            @definitions = []
        end

        def parse_string(content)
            instance_eval content
        end

        def compressor(name, options = {})
        end

        def js(filename, &block)
            defs = JSDefinitions.new(self, filename)
            defs.instance_eval(&block)
            definitions << defs
        end

        class Definitions
            attr_reader :files, :compressor, :filename

            def initialize(pocket, filename)
                @files = []
                @filename = filename
                @compressor = nil
                @separator = ""
            end

            def use(pattern)
                @files << pattern
            end

            def compress(name, options = {})
                @compressor = {:name => name, :options => {}}
            end

            def separator(new_value = nil)
                @separator = new_value unless new_value.nil?
                @separator
            end

        end

        class JSDefinitions < Definitions
        end

    end
end
