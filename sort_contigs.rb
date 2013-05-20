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
    options[:file]
    opts.on('-f','--file','The contigs file in fasta format'){ |file|
        options[:file] = file
    }
    options[:rev]
    opts.on('-r','--reverse','Sort in reverse order (shortest contigs first)'){
        options[:rev] = true
    }
    options[:sel_count]
    opts.on('-s','--sel_count','Select number of front contigs to be copied into separete file'){ |sel_count|
        options[:sel_count]
    }
}

optparse.parse!

if(options[:file].nil?)
    puts "Contigs file must be specified"
    raise OptionParser::MissingArgument, "file = \'#{options[:file]}\'"
end

#create comparison op
COMP = options[:rev] ? "<" : ">"

#create execution id
EXECUTION_ID = "#{Time.now.to_f}".sub(".","-")

#copy contigs file into tmp file
DIR = "./"
%x(cp #{options[:file]} #{DIR}#{EXECUTION_ID})

#sort tmp file
sorter = ContigSorter.new(COMP,EXECUTION_ID,DIR)
sorted_filename = sorter.sort()

#select top sel_count contigs and copy to tmp file
sel_count = options[:sel]
selectedContigs_filename = "#{sorted_filename}.sel_#{sel_count}"
sorter.cpTopContigs(sorted_filename,selectedContigs_filename,sel_count)

