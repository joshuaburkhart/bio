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
def sort_file(filename,depth=0)
    if(containsMinContigs(filename,2))
        filename_L = "#{EXECUTION_ID}_L_#{depth}"
        filename_R = "#{EXECUTION_ID}_R_#{depth}"
        filehandl_L = File.open(filename_L,"w")
        filehandl_R = File.open(filename_R,"w")
        count = 0
        while(nextContig = getNextContig(filename))
            if(count % 2 == 0)
                filehandl_L.write(nextContig)
            else
                filehandl_R.write(nextContig)
            end
        end
        filehandl_L.close
        filehandl_R.close
        
        filename_M = "#{EXECUTION_ID}_M_#{depth}"
        merge_files(filename_L,filename_R,filename_M)

        filehandl_O = File.open(filename,"r")
        filehandl_O.close
    else
        return filename
    end
end

def merge_files(filename_L, filename_R, filename_M)
    if(containsMinContigs(filename_L,1) && containsMinContigs(filename_R,1)

    elsif(containsMinContigs(filename_L,1)

    elsif(containsMinContigs(filename_R,1)

    else

    end
end

#write sorted file to disk

#select top sel_count contigs and copy to tmp file
