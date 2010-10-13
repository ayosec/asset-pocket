
Feature: Rails integration

    @rails
    Scenario: create a new application and define a pocket with some files
        Given a rails application in a temporary directory
        And a file named "app/views/css/a.css" with "1"
        And a file named "app/views/css/b.css" with "2"
        And the application has a pocket with:
        """
        css "public/stylesheets/application.css" do
            use "app/views/css/*"
            separator "\n"
        end
        """
        When update the pocket
        Then a file named "public/stylesheets/application.css" contains "1\n2"

