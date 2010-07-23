
module AssetPocket
    class Compressor

        class Error < StandardError; end

        class <<self
            attr_accessor :available

            def parse(name, options = {})
                name = name.to_s
                if not available.has_key?(name)
                    if handler = options[:handler]
                        available[name] = handler
                    else
                        raise Error, "Unknown compressor: #{name}"
                    end
                end

                hanlder = available[name]
                options.each_pair {|key, value| hanlder.send("#{key}=", value) unless key == :handler }

                hanlder
            end
        end

        self.available = {}
    end
end
