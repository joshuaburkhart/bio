#!/usr/bin/ruby

#Usage: count_quads.rb <coordinate file>

#Example: count_quads.rb WI-WIOB.minus-KC-WI.minus.combined

fh = File.open(ARGV[0],"r")
q1 = 0
q2 = 0
q3 = 0
q4 = 0
while(line = fh.gets)
    x = Float(line.split(/\s/)[0])
    y = Float(line.split(/\s/)[1])
    if(x > 0 && y > 0)
        q1 += 1
    elsif(x < 0 && y > 0)
        q2 += 1
    elsif(x < 0 && y < 0)
        q3 += 1
    elsif(x > 0 && y < 0)
        q4 += 1
    else
        puts "UNKOWN ERROR OCCURRED"
    end 
end
total = q1 + q2 + q3 + q4
puts "Quadrant 1 Count: #{q1} (#{(q1 / Float(total)) * 100}%)"
puts "Quadrant 2 Count: #{q2} (#{(q2 / Float(total)) * 100}%)"
puts "Quadrant 3 Count: #{q3} (#{(q3 / Float(total)) * 100}%)"
puts "Quadrant 4 Count: #{q4} (#{(q4 / Float(total)) * 100}%)"
puts "Total Count: #{total}"
fh.close
