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

#create auto_incrementing var
file_count = 0;

#copy contigs file into tmp file
%x(cp #{options[:file]} ./#{EXECUTION_ID})

#sort tmp file
contigs_filename = options[:file]
sorted_filename = sort(contigs_filename)

#select top sel_count contigs and copy to tmp file
sel_count = options[:sel]
selectedContigs_filename = "#{sorted_filename}.sel_#{sel_count}"
cpTopContigs(sorted_filename,selectedContigs_filename,sel_count)

def getFileCount()
    file_count += 1
    return file_count
end

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
    filehandl.close
    return length
end

def popTopContig(filename)
    cp_filename = "#{filename}.tmp"
    filehandl = File.open(filename,"r")
    topContig = nil
    contig_label = filehandl.gets
    if(contig_label.match(/^>/)
       topContig = contig_label
       while(line = filehandl.gets && line.match(/(^[ATCGNatcgn]*\n?$)/)
             topContig = "#{topContig}#{line}"
       end
       cp_filehandl = File.open(cp_filename,"w")
       while(line = filehandl.gets)
           cp_filehandl.puts(line)
       end
       filehandl.close
       cp_filehandl.close
       File.delete(filename)
       File.rename(cp_filename,filename)
    else
        filehandl.close
        puts "wtf malformed contig label '#{contig_label}' detected"
        exit(1)
    end
    return topContig
end

def append(filename, contig)
    filehandl = File.open(filename,"a")
    filehandl.puts(contig)
    filehandl.close
end

def cpTopContigs(filename,cp_filename,lim)
    filehandl = File.open(filename,"r")
    count = 0
    while(count < lim)
        contig_label = filehandl.gets
        if(contig_label.match(/^>/)
           contig = contig_label
           while(line = filehandl.gets && line.match(/(^[ATCGNatcgn]*\n?$)/)
                 contig = "#{topContig}#{line}"
           end
           cp_filehandl = File.open(cp_filename,"w")
           cp_filehandl.puts(contig)
           cp_filehandl.close
        else
            filehandl.close
            puts "wtf malformed contig label '#{contig_label}' detected"
            exit(1)
        end
    end
    filehandl.close
end


