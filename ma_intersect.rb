#!/usr/bin/ruby

#Usage: ma_intersect.rb <ma file 1> ... <ma file n>

#Example:

#NOTE: This program produces a file described below.
#
#~.intsct.csv => intersect ma data file

class Array
    attr_accessor :qval_tot
    def qval_tot=(qval)
        if(@qval_tot.nil?)
            @qval_tot = qval
        else
            @qval_tot += qval
        end
    end
end

DerivedDataRow = Struct.new(:gene,:minus,:avg,:diff,:t,:pvalue,:qvalue,:sig,:b)

common_genes = Hash.new
line_count = 0
ARGV.each_with_index { |ma_filename,i|
    ma_filehandl = File.open(ma_filename,"r")
    ma_header = ma_filehandl.gets
    while(ma_dataline = ma_filehandl.gets)
        if(line_count % 1000 == 0)
            print "."
            STDOUT.flush
        end
        ma_dataline_ary = ma_dataline.split(/\s/)
        gene = ma_dataline_ary[0]
        if(i == 0 || (!common_genes[gene].nil? && common_genes[gene].length == i))
            minus = Float(ma_dataline_ary[1])
            avg = Float(ma_dataline_ary[2])
            diff = Float(ma_dataline_ary[3])
            t = Float(ma_dataline_ary[4])
            pvalue = Float(ma_dataline_ary[5])
            qvalue = Float(ma_dataline_ary[6])
            sig = ma_dataline_ary[7]
            b = Float(ma_dataline_ary[8])
            if(common_genes[gene].nil?)
               common_genes[gene] = Array.new
            end
            common_genes[gene] << DerivedDataRow.new(gene,minus,avg,diff,t,pvalue,qvalue,sig,b)
            common_genes[gene].qval_tot = qvalue
        end
        line_count += 1
    end
    ma_filehandl.close
    puts
    puts "Maximum possible common genes: #{common_genes.size}"
    common_genes.delete_if { |key,val| val.length < (i + 1)}
    puts "After considering file #{i + 1}: #{common_genes.size}"
}
puts "--"

puts "Common genes found: #{common_genes.size}"
common_genes_ary = common_genes.values
puts "Intersection contains #{common_genes_ary.length}/#{line_count} ~ #{(common_genes_ary.length * 100) / Float(line_count).round}% of original genes."
common_genes_ary.sort! { |i,j| i.qval_tot <=> j.qval_tot}
common_genes_ary.each { |sub_ary|
    sub_ary.sort! { |i,j| i.qvalue <=> j.qvalue}
}
common_genes_ary.flatten!


intsct_filename = "#{ARGV.join("-")}.intsct.csv"
intsct_filehandl = File.open(intsct_filename,"w")
intsct_header = "Gene\tMinus\tAverage\tDifference\tt-value\tp-value\tq-value\tsignificant\tB"
intsct_filehandl.puts(intsct_header)

puts "writing results to #{intsct_filename}..."
common_genes_ary.each { |i|
    pretty_string = "#{i.gene}\t#{i.minus}\t#{i.avg}\t#{i.diff}\t#{i.t}\t#{i.pvalue}\t#{i.qvalue}\t#{i.sig}\t#{i.b}"
    intsct_filehandl.puts(pretty_string)
}

intsct_filehandl.close
puts "done."
