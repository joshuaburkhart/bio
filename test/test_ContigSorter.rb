#!/usr/local/packages/ruby/1.9.3-p194/bin/ruby

require 'test/unit'
require_relative '../ContigSorter'

class SortContigsTest < Test::Unit::TestCase

    COMP = 1
    DIR = "./test_ContigSorter_tmp_dir"
    EXECUTION_ID = "1234"
    FILENAME_S1 = "#{DIR}/#{EXECUTION_ID}s1"
    FILENAME_S2 = "#{DIR}/#{EXECUTION_ID}s2"
    FILENAME = "#{DIR}/#{EXECUTION_ID}"
    FILENAME2 = "#{FILENAME}2"
    FILENAME_M = "#{FILENAME}_M"
    CONTIG_1 = <<-EOF
>NODE_1
ATG
    EOF
    CONTIG_2 = <<-EOF
>NODE_2
ATCG
    EOF
    CONTIG_3 = <<-EOF
>NODE_3
AACCCC
    EOF
    CONTIG_4 = <<-EOF
>NODE_4
GAAAATTCCC
    EOF
    CONTIG_5 = <<-EOF
>NODE_5
AATTGGCCATGCATGC
    EOF
    CONTIG_6 = <<-EOF
>NODE_6
AAAATTTTGGGGGCCCC
    EOF
    EXAMPLE_IF = "#{CONTIG_1}#{CONTIG_2}#{CONTIG_3}"
    EXAMPLE_IF2 = "#{CONTIG_4}#{CONTIG_5}#{CONTIG_6}"

    def setup
        %x(mkdir #{DIR})
        %x(echo -n '#{EXAMPLE_IF}' > #{FILENAME})
        %x(echo -n '#{EXAMPLE_IF2}' > #{FILENAME2})
        %x(echo -n '#{CONTIG_1}' > #{FILENAME_S1})
        %x(echo -n '#{CONTIG_2}' > #{FILENAME_S2})
        @sorter = ContigSorter.new(COMP,EXECUTION_ID,DIR)
    end

    def teardown
        %x(rm -rf #{DIR}/*)
        %x(rm -rf #{DIR})
    end

    def test_tmp_file_created
        actual = %x(cat #{FILENAME})
        assert_equal(EXAMPLE_IF,actual)
    end

    def test_getFileCount
        num_files = @sorter.getFileCount()
        assert_equal(Fixnum,num_files.class)
        assert_equal(1,num_files)
    end

    def test_append
        new_file = @sorter.append(FILENAME,CONTIG_4)
        actual = %x(cat #{FILENAME})
        expected = "#{EXAMPLE_IF}#{CONTIG_4}"
        assert_equal(expected,actual)
    end

    def test_cpTopContigs
        cp_filename = "#{FILENAME}_cp"
        lim = 0
        @sorter.cpTopContigs(FILENAME,cp_filename,lim)
        actual = %x(cat #{cp_filename})
        expected = "\n"
        assert_equal(expected,actual)

        lim = 1
        @sorter.cpTopContigs(FILENAME,cp_filename,lim)
        actual = %x(cat #{cp_filename})
        expected = CONTIG_1
        assert_equal(expected,actual)

        lim = 2
        @sorter.cpTopContigs(FILENAME,cp_filename,lim)
        actual = %x(cat #{cp_filename})
        expected = "#{CONTIG_1}#{CONTIG_2}"
        assert_equal(expected,actual)

        lim = 3
        @sorter.cpTopContigs(FILENAME,cp_filename,lim)
        actual = %x(cat #{cp_filename})
        expected = "#{CONTIG_1}#{CONTIG_2}#{CONTIG_3}"
        assert_equal(expected,actual)
    end

    def test_popTopContig
        actual = @sorter.popTopContig(FILENAME)
        expected = CONTIG_1
        assert_equal(expected,actual)

        actual = %x(cat #{FILENAME})
        expected = "#{CONTIG_2}#{CONTIG_3}"
        assert_equal(expected,actual)

        actual = @sorter.popTopContig(FILENAME)
        expected = CONTIG_2
        assert_equal(expected,actual)

        actual = %x(cat #{FILENAME})
        expected = "#{CONTIG_3}"
        assert_equal(expected,actual)

        actual = @sorter.popTopContig(FILENAME)
        expected = CONTIG_3
        assert_equal(expected,actual)
        
        actual = %x(cat #{FILENAME})
        expected = "\n"
        assert_equal(expected,actual)
    end

    def test_getTopContigLength
        actual = @sorter.getTopContigLength(FILENAME)
        expected = 3
        assert_equal(expected,actual)

        actual = @sorter.getTopContigLength(FILENAME2)
        expected = 10
        assert_equal(expected,actual)

        @sorter.popTopContig(FILENAME)
        actual = @sorter.getTopContigLength(FILENAME)
        expected = 4
        assert_equal(expected,actual)

        @sorter.popTopContig(FILENAME)
        actual = @sorter.getTopContigLength(FILENAME)
        expected = 6
        assert_equal(expected,actual)
    end

    def test_containsMinContigs
        actual = @sorter.containsMinContigs(FILENAME,0)
        expected = true
        assert_equal(expected,actual)

        actual = @sorter.containsMinContigs(FILENAME,2)
        expected = true
        assert_equal(expected,actual)

        actual = @sorter.containsMinContigs(FILENAME,3)
        expected = true
        assert_equal(expected,actual)

        actual = @sorter.containsMinContigs(FILENAME,4)
        expected = false
        assert_equal(expected,actual)
    end

    def test_mergeFiles_1
        actual = @sorter.mergeFiles(FILENAME_S1,FILENAME_S2,FILENAME_M)
        expected = FILENAME_M
        assert_equal(expected,actual)

        actual = %x(cat #{FILENAME_M})
        expected = "#{CONTIG_2}#{CONTIG_1}"
        assert_equal(expected,actual)

        teardown;setup
        @sorter = ContigSorter.new(0,EXECUTION_ID,DIR)
        @sorter.mergeFiles(FILENAME_S1,FILENAME_S2,FILENAME_M)
        actual = %x(cat #{FILENAME_M})
        expected = "#{CONTIG_1}#{CONTIG_2}"
        assert_equal(expected,actual)

        teardown;setup
        @sorter = ContigSorter.new(0,EXECUTION_ID,DIR)
        @sorter.mergeFiles(FILENAME,FILENAME2,FILENAME_M)
        actual = %x(cat #{FILENAME_M})
        expected = "#{CONTIG_1}#{CONTIG_2}#{CONTIG_3}#{CONTIG_4}#{CONTIG_5}#{CONTIG_6}"
        assert_equal(expected,actual)
    end

    def test_sortFile
        actual = @sorter.sortFile(FILENAME)
        expected = "#{DIR}/#{EXECUTION_ID}_M_6"
        assert_equal(expected,actual)

        actual = %x(cat #{expected})
        expected = "#{CONTIG_3}#{CONTIG_2}#{CONTIG_1}"
        assert_equal(expected,actual)
    end
end
