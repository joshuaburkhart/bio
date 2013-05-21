#!/usr/bin/ruby

require 'optparse'
require 'time'
require_relative './ContigSorter'

options = {}

optparse = OptionParser.new { |opts|
    opts.banner = <<-EOS
Usage: sort_contigs.rb -f </path/to/contigs/file>

Example: sort_contigs.rb -f /home13/jburkhar/tmp/test1.fasta
    EOS
    opts.on('-h','--help','Display this screen'){
        puts opts
        exit
    }
    options[:file] = nil
    opts.on('-f','--file FILE','The contigs file in fasta format FILE'){ |file|
        options[:file] = file
    }
    options[:rev] = false
    opts.on('-r','--reverse','Sort in reverse order (shortest contigs first)'){
        options[:rev] = true
    }
    options[:sel_count] = nil
    opts.on('-s','--sel_count COUNT','Select number of front contigs to be copied into separete file COUNT'){ |sel_count|
        options[:sel_count]
    }
    options[:out_dir] = "/home11/mmiller/Wyeomyia/output/queue_out"
    opts.on('-o','--out_dir DIR','Output file DIR'){ |dir|
        options[:out_dir] = file
    }
}

optparse.parse!

if(options[:file].nil?)
    puts "Contigs file must be specified"
    raise OptionParser::MissingArgument, "file = \'#{options[:file]}\'"
else
    puts "params:"
    puts "file = '#{options[:file]}'"
    puts "rev = '#{options[:rev]}'"
    puts "sel_count = '#{options[:sel_count]}'"
end

#create comparison op
COMP = options[:rev] ? 0 : 1

#create execution id
EXECUTION_ID = "#{Time.now.to_f}".sub(".","-")

#copy contigs file into tmp file
DIR = options[:out_dir]
%x(cp #{options[:file]} #{DIR}/#{EXECUTION_ID})

#sort tmp file
sorter = ContigSorter.new(COMP,EXECUTION_ID,DIR)
sorted_filename = sorter.sort()

#select top sel_count contigs and copy to tmp file
sel_count = options[:sel]
selectedContigs_filename = "#{sorted_filename}.sel_#{sel_count}"
sorter.cpTopContigs(sorted_filename,selectedContigs_filename,sel_count)

