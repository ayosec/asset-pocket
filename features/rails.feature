
Feature: Rails integration
    Rails views have a helper method sprite_tag to create a HTML tag which will
    show the image.

    The rake task pocket:update will generate the pocket.

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

    @rails
    Scenario: create a CSS sprite in a rails application
        Given a rails application in a temporary directory
        And a file named "app/views/images/first.png" with a random image of 10x20
        And a file named "app/views/images/second.png" with a random image of 10x30
        And the application has a pocket with:
        """
        css "public/stylesheets/sprites.css" do
            sprite "icons" do
                layout :vertical
                use "app/views/images/*"
            end
        end
        """
        And the controller "foo" has a view "index" with:
        """
        <%= sprite_tag "icons/first" %>
        generated HTML from rails
        <%= sprite_tag "icons/second" %>
        """
        When update the pocket
        Then the sprite "icons" is generated in "public/stylesheets/sprites.css"
        And this sprite has 2 images
        And this sprite is 10x50
        And this sprite format is PNG
        And this sprite has the image "first"
        And this sprite has the image "second"
        Then the page at "/foo/index" include "generated HTML from rails"
        And this page has a tag matched with ".sprite-icons--first"
        And this page has a tag matched with ".sprite-icons--second"
