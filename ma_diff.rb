#!/usr/bin/ruby

#Usage: ma_diff.rb <minuend ma data file> <subtrahend ma data file> <outfile name>

#Example:

#NOTE: This program produces a file described below.
#
#~.diff.csv => difference ma data file

DerivedDataRow = Struct.new(:gene,:minus,:avg,:diff,:t,:pvalue,:qvalue,:sig,:b)

ma_minuend_filename = ARGV[0]
ma_minuend_filehandl = File.open(ma_minuend_filename,"r")
ma_minuend_header = ma_minuend_filehandl.gets
ma_genes = Hash.new

puts "building gene list from #{ma_minuend_filename}..."
line_count = 0
while(ma_minuend_dataline = ma_minuend_filehandl.gets)
    if(line_count % 1000 == 0)
        print "."
        STDOUT.flush
    end
    ma_minuend_dataline_ary = ma_minuend_dataline.split(/\s/)
    gene = ma_minuend_dataline_ary[0]
    minus = Float(ma_minuend_dataline_ary[1])
    avg = Float(ma_minuend_dataline_ary[2])
    diff = Float(ma_minuend_dataline_ary[3])
    t = Float(ma_minuend_dataline_ary[4])
    pvalue = Float(ma_minuend_dataline_ary[5])
    qvalue = Float(ma_minuend_dataline_ary[6])
    sig = ma_minuend_dataline_ary[7]
    b = Float(ma_minuend_dataline_ary[8])
    ma_genes[gene] = DerivedDataRow.new(gene,minus,avg,diff,t,pvalue,qvalue,sig,b)

    line_count += 1
end
puts

ma_minuend_filehandl.close
ma_sbtrhnd_filename = ARGV[1]
ma_sbtrhnd_filehandl = File.open(ma_sbtrhnd_filename,"r")
ma_sbtrhnd_header = ma_sbtrhnd_filehandl.gets

puts "filtering out genes from #{ma_sbtrhnd_filename}..."
line_count = 0
while(ma_sbtrhnd_dataline = ma_sbtrhnd_filehandl.gets)
    if(line_count % 1000 == 0)
        print "."
        STDOUT.flush
    end
    ma_sbtrhnd_gene = ma_sbtrhnd_dataline.split(/\s/)[0]
    if(ma_genes.include? ma_sbtrhnd_gene)
        ma_genes.delete(ma_sbtrhnd_gene)
    end
    line_count += 1
end
puts

ma_sbtrhnd_filehandl.close
ma_diff_ary = ma_genes.values

ma_diff_ary.sort! { |i,j|
    j.minus.abs <=> i.minus.abs
}

diff_filename = "#{ma_minuend_filename}-#{ma_sbtrhnd_filename}.diff.csv"
if(!ARGV[2].nil?)
    diff_filename = "#{ARGV[2]}.diff.csv"
end
out_header = "Gene\tMinus\tAverage\tDifference\tt-value\tp-value\tq-value\tsignificant\tB"
diff_filehandl = File.open(diff_filename,"w")
diff_filehandl.puts(out_header)

puts "writing results to #{diff_filename}..."
ma_diff_ary.each { |i|
    pretty_string = "#{i.gene}\t#{i.minus}\t#{i.avg}\t#{i.diff}\t#{i.t}\t#{i.pvalue}\t#{i.qvalue}\t#{i.sig}\t#{i.b}"
    diff_filehandl.puts(pretty_string)
}

diff_filehandl.close
puts "done."
