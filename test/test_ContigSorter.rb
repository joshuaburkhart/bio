require 'test/unit'
require_relative '../ContigSorter'

class SortContigsTest < Test::Unit::TestCase

    COMP = ">"
    EXECUTION_ID = "1234"
    DIR = "./test_ContigSorter_tmp_dir"

    def setup
        %x(mkdir #{DIR})
        @sorter = ContigSorter.new(

    def test_getFileCount
        a = getFileCount()
        assert_class(FixNum,a)
    end

end
