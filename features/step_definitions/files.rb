
Before do
    @created_files = []
    @temp_dir = make_temp_directory

    AssetPocket::SourceFilter::Sass.default_options[:cache_location] = @temp_dir.join("sass-cache").to_s
end

After do
    @created_files.each do |filename|
        filename.delete
        filename.dirname.rmdir_when_empty
    end
end

Given /^a file named "([^"]*)" with "([^"]*)"$/ do |filename, content|
    filename = @temp_dir.join(filename)
    filename.exist?.should be_false

    @created_files.unshift filename
    filename.dirname.mkpath
    filename.open("w") {|f| f.write content }
end

When /^generate a pocket with:$/ do |pocket_content|
    generator = AssetPocket::Generator.new
    generator.root_path = @temp_dir
    generator.parse_string pocket_content
    generator.run!
end

Then /^a file named "([^"]*)" contains "([^"]*)"$/ do |filename, content|
    filename = @temp_dir.join(filename)
    filename.file?.should be_true
    filename.read.inspect[1..-2].should eql(content)
end

