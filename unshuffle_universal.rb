#!/usr/bin/ruby

#Usage: ruby unshuffle.rb <path/to/shuffled/filename> <sequence identifier>

#Example: ruby unshuffle.rb /home11/mmiller/Wyeomyia/reads/combined/wy_prefiltered_reads.fastq @HWI-72047

shuffled_filename = ARGV[0]
seq_id = ARGV[1]
shuffled_filename.match(/^.*\/(\w+)(\.\w*)*$/)
unshuf_filehandl1 = File.open("#{$1}-unshuf_1.fastq","w")
unshuf_filehandl2 = File.open("#{$1}-unshuf_2.fastq","w")

File.open(shuffled_filename,"r") do |shuffled_file|
	while shuffled_file_line = shuffled_file.gets
		if shuffled_file_line.match(/^#{seq_id}.*1$/)
			unshuf_filehandl1.print shuffled_file_line #sequence id
			unshuf_filehandl1.print shuffled_file.gets #raw sequence letters
			unshuf_filehandl1.print shuffled_file.gets #+
			unshuf_filehandl1.print shuffled_file.gets #quality score
		elsif shuffled_file_line.match(/^#{seq_id}.*2$/)
			unshuf_filehandl2.print shuffled_file_line #sequence id
			unshuf_filehandl2.print shuffled_file.gets #raw sequence letters
			unshuf_filehandl2.print shuffled_file.gets #+ line
			unshuf_filehandl2.print shuffled_file.gets #quality score
		end
	end
	unshuf_filehandl1.puts
	unshuf_filehandl2.puts
	unshuf_filehandl1.close
	unshuf_filehandl2.close
    shuffled_file.close
end
