#!/usr/bin/ruby

#Usage: ma_inverter.rb <ma data file to invert> <output filename>

#NOTE: this program produces an output file with specified filename containing MA values reflected about 0 (i.e. multiplied by -1)

MADataRow = Struct.new(:gene,:M,:A,:t,:pvalue,:qvalue,:B)

fn    = ARGV[0]
outFn = ARGV[1]

fh = File.open(fn,"r")
outFh = File.open(outFn,"w")

outFh.puts(fh.gets) #1-line header

puts "writing inverted values from #{fn} to #{outFn}..."

count = 0 
while(dataLine = fh.gets)
    if(count % 1000 == 0)
        print "." 
        STDOUT.flush
    end 
    dataLineAry = dataLine.split(/\s/)
    gene        = dataLineAry[0]
    _M          = -1 * Float(dataLineAry[1]) #the only calculation
    _A          = Float(dataLineAry[2])
    t           = Float(dataLineAry[3])
    pvalue      = Float(dataLineAry[4])
    qvalue      = Float(dataLineAry[5])
    _B          = Float(dataLineAry[6])

    outDataRow  = MADataRow.new(gene,_M,_A,t,pvalue,qvalue,_B)
    
    outFh.puts "#{outDataRow.gene}\t#{outDataRow.M}\t#{outDataRow.A}\t#{outDataRow.t}\t#{outDataRow.pvalue}\t#{outDataRow.qvalue}\t#{outDataRow.B}"

    count += 1
end 
fh.close
outFh.close
puts
puts "done."
