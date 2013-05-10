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

#create comparison op
COMP = options[:rev] ? "<" : ">"

#create execution id
EXECUTION_ID = "#{Time.now.to_f}".sub(".","-")

#copy contigs file into tmp file
%x(cp #{options[:file]} ./#{EXECUTION_ID})

file_count = 0;

def getFileCount()
    file_count += 1
    return file_count
end

#sort tmp file
def sortFile(filename)
    if(containsMinContigs(filename,2))
        filename_L = "#{EXECUTION_ID}_L_#{getFileCount()}"
        filename_R = "#{EXECUTION_ID}_R_#{getFileCount()}"
        contig_counter = 0
        while(nextContig = popTopContig(filename))
            if(contig_counter % 2 == 0)
                append(filename_L)
            else
                append(filename_R)
            end
            contig_counter += 1
        end

        filename_L = sortFile(filename_L,getFileCount())
        filename_R = sortFile(filename_R,getFileCount())

        return mergeFiles(filename_L,filename_R,filename_M)
    else
        return filename
    end
end

def mergeFiles(filename_L, filename_R, filename_M)
    while(containsMinContigs(filename_L,1) || containsMinContigs(filename_R,1)
          if(containsMinContigs(filename_L,1) && containsMinContigs(filename_R,1)
             length_L = getTopContigLength(filename_L)
             length_R = getTopContigLength(filename_R)
             firstContig = eval("length_L #{COMP} length_R") ? popTopContig(filename_L) : popTopContig(filename_R)
             append(filename_M,firstContig)
          elsif(containsMinContigs(filename_L,1)
                append(filename_M,popTopContig(filename_L)
          else(containsMinContigs(filename_R,1)
               append(filename_M,popTopContig(filename_R)
          end
    end
    return filename_M
end

def containsMinContigs(filename, min_limit)
    filehandl = File.open(filename,"r")
    contig_count = 0
    while(line = filehandl.gets && contig_count < min_limit)
        if(line.match(/^>/)
           contig_count += 1
        end
    end
    filehandl.close
    return contig_count >= min_limit
end

def getTopContigLength(filename)
    filehandl = File.open(filename,"r")
    length = 0
    contig_label = filehandl.gets
    if(contig_label.match(/^>/)
        while(line = filehandl.gets && line.match(/(^[ATCGNatcgn]*\n?$)/)
              length += line.count("ATCGNatcgn")
        end
    else
        puts "wtf malformed contig label '#{contig_label}' detected"
        exit(1)
    end
    return length
end

def popTopContig(filename)

end

def append(filename, contig)

end

#write sorted file to disk

#select top sel_count contigs and copy to tmp file
