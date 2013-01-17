#!/usr/bin/ruby

#Usage: maparser.rb <ma data file>

#Example: maparser.rb limma.KC-WI.gene.de.txt

#NOTE: This program produces the three output files described below.
#
#~.pos.csv => file containing rows with significant positive ma expression
#~.neg.csv => file containing rows with significant negative ma expression

DerivedDataRow = Struct.new(:gene,:minus,:avg,:diff,:t,:pvalue,:qvalue,:sig,:b)

ma_filename = ARGV[0]
ma_filehandl = File.open(ma_filename,"r")
ma_header = ma_filehandl.gets
ma_results = Array.new

puts "reading #{ma_filename}..."
line_count = 0
while(ma_dataline = ma_filehandl.gets)
    if(line_count % 10000 == 0)
        print "."
        STDOUT.flush
    end
    ma_dataline_ary = ma_dataline.split(/\s/)

    gene = ma_dataline_ary[0]
    minus = Float(ma_dataline_ary[1])
    avg = Float(ma_dataline_ary[2])
    t = Float(ma_dataline_ary[3])
    pvalue = Float(ma_dataline_ary[4])
    qvalue = Float(ma_dataline_ary[5])
    b = Float(ma_dataline_ary[6])

    diff = minus - avg
    sig = qvalue < 0.05

    ma_results << DerivedDataRow.new(gene,minus,avg,diff,t,pvalue,qvalue,sig,b)

    line_count += 1
end
puts

ma_filehandl.close

ma_results.sort! { |i,j|
    j.minus.abs <=> i.minus.abs
}

pos_filehandl = File.open("#{ma_filename}.pos.csv","w")
neg_filehandl = File.open("#{ma_filename}.neg.csv","w")

out_header = "Gene\tMinus\tAverage\tDifference\tt-value\tp-value\tq-value\tsignificant\tB"

pos_filehandl.puts(out_header)
neg_filehandl.puts(out_header)

puts "writing results..."
ma_results.each { |i|
    if(i.sig == true)
        pretty_string = "#{i.gene}\t#{i.minus}\t#{i.avg}\t#{i.diff}\t#{i.t}\t#{i.pvalue}\t#{i.qvalue}\t#{i.sig}\t#{i.b}"
        if(i.minus > 0)
            pos_filehandl.puts(pretty_string)
        elsif(i.minus < 0)
            neg_filehandl.puts(pretty_string)
        end
    end
}

pos_filehandl.close
neg_filehandl.close

puts "done."

