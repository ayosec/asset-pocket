
module AssetPocket
    module SourceFilter
        extend self

        module Sass
            extend self

            attr_accessor :default_options
            self.default_options = {
                 :css_location => "./tmp/sass-cache"
            }

            def render(filename, content)
                options = { :filename => filename }.merge(default_options)

                if filename =~ /\.sass$/i
                    options[:syntax] = :sass
                elsif filename =~ /\.scss$/i
                    options[:syntax] = :scss
                else
                    return content
                end

                require 'sass' # Load only when needed

                begin
                    ::Sass::Engine.new(content, options).render

                rescue ::Sass::SyntaxError => error
                    "/* #{File.basename(filename)}: #{error.to_s.gsub("*/", "* /")} */"
                end
            end
        end

        Filters = [
            [ /.*\.s[ac]ss$/i, Sass.method(:render) ]
        ]

        def filter(filename)
            content = File.read filename

            Filters.each do |filter|
                if filename =~ filter[0]
                    return filter[1].call filename, content
                end
            end

            content
        end
    end
end
