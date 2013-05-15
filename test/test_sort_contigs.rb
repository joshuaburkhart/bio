require 'test/unit'
require_relative '../sort_contigs.rb'

class SortContigsTest < Test::Unit::TestCase

    def test_getFileCount
        a = getFileCount()
        assert_class(FixNum,a)
    end

end
