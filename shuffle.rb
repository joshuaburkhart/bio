#!/usr/bin/ruby

#Usage: ruby shuffle.rb <path/to/unshuffled/filename1> <path/to/unshuffled/filename2> <sequence identifier>

#Example: ruby shuffle.rb /home11/mmiller/Wyeomyia/reads/combined/wy_prefiltered_reads_R1.fastq /home11/mmiller/Wyeomyia/reads/combined/wy_prefiltered_reads_R1.fastq @HWI-72047

unshuffled_filename1 = ARGV[0]
unshuffled_filename2 = ARGV[1]
seq_id = ARGV[2]
unshuffled_filename1.match(/^.*\/(\w+?)\.\w+$/)
name1 = $1
unshuffled_filename2.match(/^.*\/(\w+?)\.\w+$/)
name2 = $1
shuf_filehandl = File.open("#{name1}-#{name2}-shuf.fastq","w")

#TODO
#filter paired reads with Y indicators (low quality indicators)

unshuffled_filehandl1 = File.open(unshuffled_filename1,"r")
unshuffled_filehandl2 = File.open(unshuffled_filename2,"r")
while(unshuffled_file_line1 = unshuffled_filehandl1.gets)
    if unshuffled_file_line.match(/^#{seq_id}.* 1:[NY]:.*$/)
        shuf_filehandl.print unshuffled_file_line1 #sequence id
        shuf_filehandl.print unshuffled_filehandl1.gets #raw sequence letters
        shuf_filehandl.print unshuffled_filehandl1.gets #+
        shuf_filehandl.print unshuffled_filehandl1.gets #quality score
        shuf_filehandl.print unshuffled_filehandl2.gets #sequence id
        shuf_filehandl.print unshuffled_filehandl2.gets #raw sequence letters
        shuf_filehandl.print unshuffled_filehandl2.gets #+ line
        shuf_filehandl.print unshuffled_filehandl2.gets #quality score
    else
        puts "wtf error"
        exit
    end
end
unshuffled_filehandl1.close
unshuffled_filehandl2.close
shuf_filehandl.puts
shuf_filehandl.close
