
def random_image(filename, width, height)
    img = Magick::Image.new(width, height)
    img.import_pixels 0, 0, width, height, "RGB", File.read("/dev/urandom", width*height*3)

    filename = @temp_dir.join(filename)
    filename.dirname.mkpath
    img.write filename.to_s

    @created_images.unshift filename
end

Before do
    @created_images = []
    @temp_dir = make_temp_directory
end

After do
    @created_images.each do |filename|
        filename.delete
        filename.dirname.rmdir_when_empty
    end
end


Given /^(\d+) random images at "([^"]*)" with a random image of (\d+)x(\d+)$/ do |count, pattern, width, height|
    width = width.to_i
    height = height.to_i
    count.to_i.times do |iter|
        random_image pattern.sub("NN", iter.to_s), width, height
    end
end

Given /^a file named "([^"]*)" with a random image of (\d+)x(\d+)$/ do |filename, width, height|
    random_image filename, width.to_i, height.to_i
end


def just_parse_css(content)
    content.scan(/(\S+)\s*\{(.*?)\}/m).inject({}) do |hash, item|
        rule, attributes = item
        hash[rule] = attributes.split(";").map {|attribute| attribute.strip }
        hash
    end
end

Then /^the sprite "([^"]*)" is generated in "([^"]*)"$/ do |sprite, css_file|
    Then %|the sprite "#{sprite}" encoded in \\w+ is generated in "#{css_file}"|
end

Then /^the sprite "([^"]*)" encoded in (\S+) is generated in "([^"]*)"$/ do |sprite, format, css_file|
    css_file = @temp_dir.join(css_file)
    @css_loaded = just_parse_css(css_file.read)
    @css_loaded.should include_key(/\.sprite-#{sprite}--/)

    @sprite = @css_loaded.reject {|key, value| key !~ /\.sprite-#{sprite}--/ or value.join !~ /url\([^)]+\.#{format}\)/i }
    @image_sprite = Magick::Image.read(css_file.dirname.join(@sprite.values.to_s.first =~ /url\((.*?\.#{format})\)/i && $1).to_s).first
end

Then /^this sprite has (\d+) images?$/ do |count|
    @sprite.size.should eql(count.to_i)
end

Then /^this sprite is (\d+)x(\d+)$/ do |width, height|
    @image_sprite.columns.should eql(width.to_i)
    @image_sprite.rows.should eql(height.to_i)
end

Then /^this sprite format is (\S+)$/ do |format|
    @image_sprite.format.downcase.should eql(format.downcase)
end
