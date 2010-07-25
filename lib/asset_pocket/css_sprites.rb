
require 'RMagick'
require 'md5'

module AssetPocket
    class Pocket
        class SpriteDefition
            attr_accessor :layout
            attr_reader :name, :css_block, :images_location

            def initialize(name, css_block)
                @name = name
                @css_block = css_block
                @files = {}
                @layout = :vertical

                self.images_location = "../images/"
            end

            def images_location=(location)
                @images_location = css_block.pocket.generator.root_path.join(css_block.filename).dirname.join(location)
            end

            def generate!
                @images_location.mkpath

                @files.each_pair do |format, images|

                    sprite_name = @images_location.join("sprite-#{name}.#{format.downcase}")
                    url_css_sprite = sprite_name.relative_path_from(css_block.full_filename.dirname)

                    # Compute the canvas size
                    width = 0
                    height = 0

                    distribute_images images do |image, cx, cy|
                        cx = cx + image.columns
                        cy = cy + image.rows

                        height = cy if cy > height
                        width = cx if cx > width
                    end

                    canvas = Magick::Image.new(width, height)
                    canvas.format = format

                    distribute_images images do |image, cx, cy|
                        canvas.composite! image, cx, cy, Magick::OverCompositeOp

                        css = ".sprite.sprite-#{name}--#{File.basename(image.filename).gsub(/\.\w+$/, "")} {"
                        css << "background: url(#{url_css_sprite}) -#{cx}px -#{cy}px;"
                        css << "width: #{image.columns}px;"
                        css << "height: #{image.rows}px;"
                        css << "} \n"
                        css_block.content << [ :string, css]
                    end

                    images.clear
                    canvas = canvas.to_blob

                    sprite_name.open("w") {|f| f.write canvas }
                end
            end

            def use(pattern)
                @files ||= []
                Dir[css_block.pocket.generator.root_path.join(pattern)].each do |image_file|
                    begin
                        image = Magick::Image.read(image_file)
                        if image.size != 1
                            # Animated images can not be sprited
                            # TODO log the action
                            next
                        end

                        image = image.first

                    rescue Magick::ImageMagickError
                        # TODO log the error
                        next
                    end

                    @files[image.format] ||= []
                    @files[image.format] << image
                end
            end

        private
            def distribute_images(images, &block)
                cx = cy = 0
                valid_layout = true

                case layout
                when :vertical
                    images.each do |image|
                        block.call image, cx, cy
                        cy += image.rows
                    end

                when :horizontal
                    images.each do |image|
                        block.call image, cx, cy
                        cx += image.columns
                    end

                when Hash
                    if layout[:columns]
                        column = 0
                        row_height = 0
                        columns_per_row = layout[:columns]

                        images.each do |image|
                            column += 1
                            if column > columns_per_row
                                column = 1
                                cx = 0
                                cy += row_height
                                row_height = 0
                            end

                            block.call image, cx, cy
                            cx += image.columns
                            row_height = image.rows if image.rows > row_height
                        end

                    else
                        valid_layout = false
                    end

                else
                    valid_layout = false
                end

                unless valid_layout
                    raise ArgumentError, "Unknown layout: #{layout} in sprite #{name}"
                end
            end
        end
    end
end
