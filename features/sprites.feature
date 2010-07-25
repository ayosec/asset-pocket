
Feature: generate CSS sprites from the pocket

    @sprites
    Scenario: create a simple sprite with different images
        Given a file named "images/a.png" with a random image of 10x10
        And a file named "images/b.png" with a random image of 10x20
        And a file named "images/c.png" with a random image of 20x20
        When generate a pocket with:
        """
        css "sprites/css/first.css" do
            sprite "all" do
                layout :vertical
                use "images/*"
            end
        end
        """
        Then the sprite "all" is generated in "sprites/css/first.css"
        And this sprite has 3 images
        And this sprite is 20x50
        And this sprite format is PNG

    @sprites
    Scenario Outline: sprites can be generated with different layoutes
        Given 20 random images at "images/<case>/firstNN.png" with a random image of 10x30
        When generate a pocket with:
        """
        css "sprites/css/<case>.css" do
            sprite "all-<case>" do
                layout <layout>
                use "images/<case>/*"
            end
        end
        """
        Then the sprite "all-<case>" is generated in "sprites/css/<case>.css"
        And this sprite has 20 images
        And this sprite is <size>
        And this sprite format is PNG

        Scenarios:
            | case       | layout        | size   |
            | vertical   | :vertical     | 10x600 |
            | horizontal | :horizontal   | 200x30 |
            | table      | :columns => 5 | 50x120 |

    @sprites
    Scenario: different formats create different sprites
        Given a file named "images/a.png" with a random image of 10x10
        And a file named "images/b.png" with a random image of 10x20
        And a file named "images/c.gif" with a random image of 20x20
        And 10 random images at "images/firstNN.jpeg" with a random image of 10x30
        When generate a pocket with:
        """
        css "sprites/css/multiformat.css" do
            sprite "multiformat" do
                layout :vertical
                use "images/*"
            end
        end
        """
        Then the sprite "multiformat" encoded in PNG is generated in "sprites/css/multiformat.css"
        And this sprite has 2 images
        And this sprite is 10x30
        And the sprite "multiformat" encoded in GIF is generated in "sprites/css/multiformat.css"
        And this sprite has 1 image
        And this sprite is 20x20
        And the sprite "multiformat" encoded in JPEG is generated in "sprites/css/multiformat.css"
        And this sprite has 10 images
        And this sprite is 10x300
