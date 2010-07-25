
def include_key(regexp)
    simple_matcher("include a key that matchs #{regexp.inspect}") do |given|
        given.keys.grep(regexp).size > 0
    end
end
