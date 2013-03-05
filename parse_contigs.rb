#!/usr/bin/ruby

#Usage: parse_contigs.rb <filename> <lines per file>

#Example:
#
#[jburkhar@hn1 tmp]$ echo $(($(cat contigs.fasta | wc -l) / 10))
#4809
#[jburkhar@hn1 tmp]$ parse_contigs.rb contigs.fasta 4809
#[jburkhar@hn1 tmp]$ 

filename = ARGV[0]
lines_per_file = ARGV[1]
if(filename.nil? || lines_per_file.nil?)
    puts "Usage: parse_contigs.rb <filename> <lines per file>"
    exit
end

filehandl = File.open(filename,"r")
count = 0
new_file_affix = 1
new_file_handl = nil
last_file_line = nil
while(file_line = filehandl.gets)
    if(count == 0)
        new_file_name = "new_contigs_#{new_file_affix}.fasta"
        new_file_handl = File.open(new_file_name,"w")
    end
    if(count < Float(lines_per_file))
        if(file_line.match(/^(.*[0-9]+)([a-zA-Z]+)/))
            title = ">#{$1}"
            data = $2
            new_file_handl.puts(title)
            new_file_handl.puts(data)
           count += 1
        end
    else
        new_file_handl.close
        count = 0
        new_file_affix += 1
    end
end

