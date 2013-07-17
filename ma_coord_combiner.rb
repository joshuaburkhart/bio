#!/usr/bin/ruby

#Usage: ma_coord_combiner.rb <x coordinates> <y coordinates>

#Example: ma_coord_combiner.rb WI-WIOB.minus KC-WI.minus

x_coordhandl = File.open(ARGV[0],"r")
y_coordhandl = File.open(ARGV[1],"r")
outfilehandl = File.open("#{ARGV[0]}-#{ARGV[1]}.combined","w")

while(x = x_coordhandl.gets)
    y = y_coordhandl.gets
    outfilehandl.puts("#{x.strip} #{y.strip}")
end

x_coordhandl.close
y_coordhandl.close
outfilehandl.close
