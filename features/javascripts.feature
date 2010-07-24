
Feature: JavaScripts Pocket

    @javascript
    Scenario: combine several files just concat them
        Given a file named "sources/foo.js" with "foo();"
        And a file named "sources/bar.js" with "bar();"
        When generate a pocket with:
        """
        js "generated/dest.js" do
            use "sources/foo.js"
            use "sources/bar.js"
        end
        """
        Then a file named "generated/dest.js" contains "foo();bar();"

    @javascript
    Scenario: combine several files with a separator
        Given a file named "sources/foo.js" with "foo();"
        And a file named "sources/bar.js" with "bar();"
        When generate a pocket with:
        """
        js "generated/dest.js" do
            use "sources/foo.js"
            use "sources/bar.js"

            separator "|"
        end
        """
        Then a file named "generated/dest.js" contains "foo();|bar();"


    @javascript
    Scenario: a pattern can be used to append files sorted by name
        Given a file named "sources/a/a.js" with "1"
        And a file named "sources/c/b.js" with "5"
        And a file named "sources/a/b.js" with "2"
        And a file named "sources/b/a.js" with "4"
        And a file named "sources/a/c.js" with "3"
        When generate a pocket with:
        """
        js "generated/everything.js" do
            use "sources/**/*.js"
        end
        """
        Then a file named "generated/everything.js" contains "12345"

    @javascript
    Scenario: a custom compressor can be defined in the configuration
        Given a file named "sources/foo.js" with "foo"
        And a file named "sources/bar.js" with "bar"
        When generate a pocket with:
        """
        class UpperCompressor
            def compress(content)
                content.upcase
            end
        end

        compressor :upper, :handler => UpperCompressor.new
        js "generated/upper.js" do
            compress :upper
            use "sources/**/*.js"
        end
        """
        Then a file named "generated/upper.js" contains "BARFOO"

    @javascript
    Scenario: compressors can receive parameters 
        Given a file named "sources/foo.js" with "foo"
        And a file named "sources/bar.js" with "bar"
        When generate a pocket with:
        """
        class AppendContentCompressor
            attr_accessor :extra
            def compress(content)
                content + extra
            end
        end

        compressor :append, :handler => AppendContentCompressor.new
        compressor :append, :extra => "baz"
        js "generated/append.js" do
            compress :append
            use "sources/**/*.js"
        end
        """
        Then a file named "generated/append.js" contains "barfoobaz"

