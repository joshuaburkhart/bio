#!/usr/local/packages/jruby/1.6.7.2/bin/jruby

require 'thread'
require 'optparse'
mutex = Mutex.new
options = {}

DEFAULT_OUT_FILE = './estimated_parameters.txt'
MILLION = 1000000
G = 850 * MILLION
CK_TEST_VALS = [20,25,30,35,40]
ID = @unbarcoded

optparse = OptionParser.new { |opts|
    opts.banner = <<-EOS
Usage: jruby param_ests.rb -1 </path/to/input/file/1> -2 </path/to/input/file/2> -o </path/to/output/file>

Example: jruby param_ests.rb -1 /home13/jburkhar/research/out/kmer_filter_output/sample1.fq -2 /home13/jburkhar/research/out/kmer_filter/output/sample2.fq -o /home13/jburkhar/research/output/stats/ests_0.txt
    EOS

    opts.on('-h','--help','Display this screen'){
        puts opts
        exit
    }
    options[:in_file1] = nil
    opts.on('-1','--in_file1 FILE','Input File 1'){ |file_name|
        options[:in_file1] = file_name
    }
    options[:in_file2] = nil
    opts.on('-2','--in_file2 FILE','Input File 2'){ |file_name|
        options[:in_file2] = file_name
    }
    options[:out_file] = DEFAULT_OUT_FILE
    opts.on('-o','--out_file FILE','Output File'){ |file_name|
        options[:out_file] = file_name
    }
    options[:progress] = MILLION
    opts.on('-p','--progress INTVL','Progress Indicator Interval'){ |intvl|
        options[:progress] = Integer(intvl)
    }
}
optparse.parse!

puts "ARGUMENTS PASSED:"
puts "in_file1 = #{options[:in_file1]}"
puts "in_file2 = #{options[:in_file2]}"
puts "out_file = #{options[:out_file]}"
puts

def parseFile(fh,pg,mutex,ch)
    Thread.current["nbp"] = 0
    Thread.current["n"] = 0
    progress_mon = 0
    fh_cached_line = ""
    while fh_cur_line = fh.gets
        if fh_cached_line.match(/^#{ID}/)
            Thread.current["nbp"] += fh_cur_line.size
            Thread.current["n"] += 1
            progress_mon += 1
            if progress_mon > pg
                mutex.synchronize {
                    print ch
                    STDOUT.flush
                }
                progress_mon = 0
            end

        end
        fh_cached_line = fh_cur_line
    end
end

file_stats = []
puts "working..."
if (!options[:in_file1].nil?)
    file_stats[0] = Thread.new {
        pg = options[:progress]
        fh = File.open(options[:in_file1])
        parseFile(fh,pg,mutex,'.')
        fh.close
    }
    if(!options[:in_file2].nil?)
        file_stats[1] = Thread.new {
            pg = options[:progress]
            fh = File.open(options[:in_file2])
            parseFile(fh,pg,mutex,':')
            fh.close
        }
    end
    nbp = 0
    n = 0
    file_stats.each { |t|
        t.join
        nbp += t["nbp"]
        n += t["n"]
    }
    l = Float(nbp) / n #avg read length
    c = Float(nbp) / G #nucleotide coverage
    outh = File.open("#{options[:out_file]}",'w')
    outh.puts "ESTIMATED PARAMETERS FOR:"
    outh.puts "FILE 1: #{options[:in_file1]}"
    outh.puts "FILE 2: #{options[:in_file2]}"
    outh.puts "========================="
    outh.puts

    num_sizes = [G.to_s.size,n.to_s.size,nbp.to_s.size,Integer(l).to_s.size,Integer(c).to_s.size]
    max_ln = num_sizes.max

    outh.puts "Genome Size.............#{"."*(max_ln - G.to_s.size)}#{G}"
    outh.puts "Read Count..............#{"."*(max_ln - n.to_s.size)}#{n}"
    outh.puts "Base Pair Count.........#{"."*(max_ln - nbp.to_s.size)}#{nbp}"
    outh.puts "Average Read Length.....#{"."*(max_ln - Integer(l).to_s.size)}#{"%0.3f" % l}"
    outh.puts "Nucleotide Coverage.....#{"."*(max_ln - Integer(c).to_s.size)}#{"%0.3f" % c}"

    outh.puts
    CK_TEST_VALS.each { |ck|
        outh.puts "Kmer Coverage #{ck}:"
        k = l + 1 - (Float(ck * G) / n)
        est_gbs =(-109635 + 18977 * l + 86326 * (G / MILLION) + 233353 * (n / MILLION) - 51092 * k) / 1048576
        
        num_sizes = [Integer(est_gbs).to_s.size, Integer(k).to_s.size]
        max_ln = num_sizes.max

        outh.print "Hash Length............#{"."*(max_ln - Integer(k).to_s.size)}#{"%0.3f" % k}"
        if (k < (l / 2))
            outh.print " (smaller than recommended)"
        end
        outh.print "\n"
        outh.print "Estimated Velvet RAM...#{"."*(max_ln - Integer(est_gbs).to_s.size)}#{"%0.3f" % est_gbs} GB"
        outh.puts 
        outh.puts
    }
    outh.close
    puts
    puts "done."
else
    puts "No input file specified. Exiting..."
end
