
Feature: Sass integration

    @sass
    Scenario: filenames ended with .scss are compiled with Sass
        Given a file named "sources/foo.scss" with "$color: blue; div { span { color: $color; } }"
        When generate a pocket with:
        """
        css "generated/base.css" do
            use "sources/foo.scss"
        end
        """
        Then a file named "generated/base.css" contains "div span {\n  color: blue; }\n"

    @sass
    Scenario: Sass options can be modified
        Given a file named "sources/bar.scss" with "div { span { display: block; } }"
        When generate a pocket with:
        """
        sass :style => :compressed
        css "generated/compressed.css" do
            use "sources/bar.scss"
        end
        """
        Then a file named "generated/compressed.css" contains "div span{display:block}\n"

    @sass
    Scenario: multiple Sass sources can be loaded importing them
        Given a file named "sources/one.scss" with "$color: blue;"
        And a file named "sources/two.scss" with "$background: black;"
        And a file named "sources/three.scss" with "$color: blue !default;"
        And a file named "sources/final.scss" with "div { background: $background; color: $color; }"
        When generate a pocket with:
        """
        sass :style => :compressed
        sass "generated/compressed.css" do
            import "sources/one.scss"
            import "sources/two.scss"
            import "sources/three.scss"
            import "sources/final.scss"
        end
        """
        Then a file named "generated/compressed.css" contains "div{background:black;color:blue}\n"

    @sass
    Scenario: a bundle can be created with previous bundles
        Given a file named "sources/one.css" with "div {}"
        And a file named "sources/two.css" with "span {}"
        And a file named "sources/three.scss" with "div { span { display: block; } }"
        When generate a pocket with:
        """
        css "generated/first.css" do
            use "sources/one.css"
            use "sources/two.css"

            separator "\n"
        end

        sass :style => :compressed
        css "generated/second.css" do
            use "sources/three.scss"
        end

        css "generated/both.css" do
            use "generated/first.css"
            use "generated/second.css"
        end
        """
        Then a file named "generated/both.css" contains "div {}\nspan {}div span{display:block}\n"
