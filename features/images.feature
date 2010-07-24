
Feature: copy files from one directory to another

    @files
    Scenario: keep the directory tree
        Given a file named "sources/a/one" with "1"
        And a file named "sources/a/two" with "2"
        And a file named "sources/b/three" with "3"
        And a file named "sources/b/d/four" with "4"
        When generate a pocket with:
        """
        files "generated/copied/" do
            base "sources"
            use "sources/**/*"
        end
        """
        Then a file named "generated/copied/a/one" contains "1"
        And a file named "generated/copied/a/two" contains "2"
        And a file named "generated/copied/b/three" contains "3"
        And a file named "generated/copied/b/d/four" contains "4"
