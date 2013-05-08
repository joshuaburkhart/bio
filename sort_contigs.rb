#!/usr/bin/ruby

require 'optparse'
require 'time'

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

#create execution id
EXECUTION_ID = "#{Time.now.to_f}".sub(".","-")

#copy contigs file into tmp file
%x(cp #{options[:file]} ./#{EXECUTION_ID})

#sort tmp file


#write sorted file to disk

#select top sel_count contigs and copy to tmp file
