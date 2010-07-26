
Given /^a rails application in a temporary directory$/ do
    @temp_dir = @temp_dir.join("test_pocket")
    case (`rails -v` =~ /rails (\d+)/i && $1).to_i
    when 3
        `rails new #{@temp_dir}`
        @temp_dir.join("config/initializers/rack_test.rb").open("w") {|f| f.puts <<-EOI }
            RackTestApplication = proc { Rails::Application.instance }
        EOI
    when 2
        `rails #{@temp_dir}`
        @temp_dir.join("config/initializers/rack_test.rb").open("w") {|f| f.puts <<-EOI }
            gem "rack-test"
            require 'rack/test'
            RackTestApplication = proc { ActionController::Dispatcher.new }

            class String
                def html_safe
                    self
                end
            end
        EOI
    else
        pending
    end

    plugin_dir = @temp_dir.join("vendor/plugins")
    plugin_dir.mkpath
    FileUtils.cp_r Pathname.new(__FILE__).dirname.join("../../"), plugin_dir
end

Given /^the application has a pocket with:$/ do |pocket|
    pocket_file = @temp_dir.join("config/pocket.rb")
    pocket_file.exist?.should be_false
    pocket_file.open("w") {|f| f.write pocket }
end

Given /^the controller "([^"]*)" has a view "([^"]*)" with:$/ do |controller, action, erb|
    controller_file = @temp_dir.join("app/controllers/#{controller}_controller.rb")
    if not controller_file.exist?
        controller_file.dirname.mkpath
        controller_file.open("w") {|f| f.puts "class #{"#{controller}_controller".gsub(/(?:^|_)([a-z])/) { $1.upcase }} < ApplicationController\nend" }

        # This route should works in both Rails 3 and 2
        routes = @temp_dir.join("config/routes.rb")
        current_routes = routes.read
        routes.open("w") {|f| f.write current_routes.sub(/end\s*\Z/, %[map.connect "/#{controller}/:action", :controller => "#{controller}"\nend\n]) }
    end

    view_file = @temp_dir.join("app/views/#{controller}/#{action}.html.erb")
    view_file.dirname.mkpath
    view_file.open("w") {|f| f.write erb }
end


Then /^the page at "([^"]*)" include "([^"]*)"$/ do |uri,html|
    if @temp_dir.join("script/rails").exist?
        runner = "rails runner"
    else
        runner = "script/runner"
    end

    @page_body = `cd #{@temp_dir}; #{runner} 'puts Rack::Test::Session.new(RackTestApplication.call).get("#{uri}").body'`
    @page_body.should include(html)
end

Then /^this page has a tag matched with "([^"]*)"$/ do |selector|
    @page_dom ||= Nokogiri::HTML(@page_body)
    @page_dom.search(selector).should_not be_empty
end

When /^update the pocket$/ do
    Process.wait(fork do
        Dir.chdir @temp_dir
        STDOUT.reopen "/dev/null", "w"
        exec "rake", "pocket:update"
    end)
end
