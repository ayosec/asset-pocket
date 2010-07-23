
Feature: Sass integration

    @sass
    Scenario: filenames ended with .scss are compiled with Sass
        Given a file named "sources/foo.scss" with "$color: blue; div { span { color: $color; } }"
        When generate a pocket with:
        """
        css "genereated/base.css" do
            use "sources/foo.scss"
        end
        """
        Then a file named "genereated/base.css" contains "div span {\n  color: blue; }\n"

    @sass
    Scenario: Sass options can be modified
        Given a file named "sources/bar.scss" with "div { span { display: block; } }"
        When generate a pocket with:
        """
        sass :style => :compressed
        css "genereated/compressed.css" do
            use "sources/bar.scss"
        end
        """
        Then a file named "genereated/compressed.css" contains "div span{display:block}\n"

    @sass
    Scenario: multiple Sass sources can be loaded importing them
        Given a file named "sources/one.scss" with "$color: blue;"
        And a file named "sources/two.scss" with "$background: black;"
        And a file named "sources/three.scss" with "$color: blue !default;"
        And a file named "sources/final.scss" with "div { background: $background; color: $color; }"
        When generate a pocket with:
        """
        sass :style => :compressed
        sass "genereated/compressed.css" do
            import "sources/one.scss"
            import "sources/two.scss"
            import "sources/three.scss"
            import "sources/final.scss"
        end
        """
        Then a file named "genereated/compressed.css" contains "div{background:black;color:blue}\n"

