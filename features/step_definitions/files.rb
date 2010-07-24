
Before do
    @created_files = []
    @temp_dir = "/tmp/asset_pocket_tests-#$$"

    AssetPocket::SourceFilter::Sass.default_options[:cache_location] = "#@temp_dir/sass-cache"

    unless File.directory?(@temp_dir)
        Dir.mkdir @temp_dir
    end
end

After do
    @created_files.each do |filename|
        File.unlink filename
        dirname = File.dirname(filename)
        if Dir["#{dirname}/*"].empty?
            Dir.rmdir(dirname)
        end
    end
end

Given /^a file named "([^"]*)" with "([^"]*)"$/ do |filename, content|
    filename = "#@temp_dir/#{filename}"
    File.exist?(filename).should be_false

    @created_files.unshift filename
    FileUtils.mkpath File.dirname(filename)
    File.open(filename, "w") {|f| f.write content }
end

When /^generate a pocket with:$/ do |pocket_content|
    generator = AssetPocket::Generator.new
    generator.root_path = @temp_dir
    generator.parse_string pocket_content
    generator.run!
end

Then /^a file named "([^"]*)" contains "([^"]*)"$/ do |filename, content|
    filename = "#@temp_dir/#{filename}"
    File.exist?(filename).should be_true

    File.read(filename).inspect[1..-2].should eql(content)
end

