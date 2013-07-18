#!/usr/bin/ruby
#Usage: manhattan.rb <coordinate input file> <threshold>
#
#Example: manhattan.rb WI-WIOB.minus-KC-WI.minus.combined 4

infile = ARGV[0]
threshold = Float(ARGV[1])

inhandl = File.open(infile,"r")
pos_outhandl = File.open("Manhattan>#{threshold}","w")
neg_outhandl = File.open("Manhattan<#{threshold}","w")

while(line = inhandl.gets)
    x = Float(line.split(/ /)[0])
    y = Float(line.split(/ /)[1])
    if(x > 0 && y > 0 && x + y > threshold)
        pos_outhandl.puts("#{x} #{y}")
    elsif(x < 0 && y < 0 && x + y < (-1 * threshold))
        neg_outhandl.puts("#{x} #{y}")
    end
end

inhandl.close
pos_outhandl.close
neg_outhandl.close
