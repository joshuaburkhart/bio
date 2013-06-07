#!/usr/bin/ruby

#Usage: ma_coord_combiner.rb <ma_coord file 1> <ma_coord file 2>

#Example: ma_coord_combiner.rb KC-WI.minus WI-WIOB.minus

coordfile1handl = File.open(ARGV[0],"r")
coordfile2handl = File.open(ARGV[1],"r")
outfilehandl = File.open("#{ARGV[0]}-#{ARGV[1]}.combined","w")

while(coord1 = coordfile1handl.gets)
    coord2 = coordfile2handl.gets
    outfilehandl.puts("#{coord1.strip} #{coord2.strip}")
end

coordfile1handl.close
coordfile2handl.close
outfilehandl.close
