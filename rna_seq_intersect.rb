#!/usr/bin/ruby

#Usage: rna_seq_intersect.rb <rna seq file 1> ... <rna seq file n>

#Example:

#NOTE: This program produces a file described below.
#
#~.intsct.csv => intersect rna seq data file

QVAL = 0.4

class Array
    attr_accessor :qval_tot
    def qval_tot=(qval)
        if(qval == "NA")
            qval = 0.0
        end
        if(@qval_tot.nil?)
            @qval_tot = qval
        else
            @qval_tot += qval
        end
    end
end

DerivedDataRow = Struct.new(:nolab,:id,:baseMean,:baseMeanA,:baseMeanB,:foldChange,:log2foldChange,:pval,:qval)

common_id = Hash.new
total_line_count = 0
individual_line_counts = Array.new
ARGV.each_with_index { |filename,i|
    individual_line_counts[i] = 0
    filehandl = File.open(filename,"r")
    header = filehandl.gets
    while(dataline = filehandl.gets)
        if(total_line_count % 1000 == 0)
            print "."
            STDOUT.flush
        end
        dataline_ary = dataline.split(/,/)
        id = dataline_ary[1]
        if(i == 0 || (!common_id[id].nil? && common_id[id].length == i))
            qval = dataline_ary[8].to_f
            if(0.0 < qval && qval < QVAL)
                nolab = dataline_ary[0]
                id = dataline_ary[1]
                baseMean = dataline_ary[2]
                baseMeanA = dataline_ary[3]
                baseMeanB = dataline_ary[4]
                foldChange = dataline_ary[5]
                log2foldChange = dataline_ary[6]
                pval = dataline_ary[7]
                if(common_id[id].nil?)
                    common_id[id] = Array.new
                end
                common_id[id] << DerivedDataRow.new(nolab,id,baseMean,baseMeanA,baseMeanB,foldChange,log2foldChange,pval,qval)
                common_id[id].qval_tot = qval
            end
        end
        individual_line_counts[i] += 1
        total_line_count += 1
    end
    filehandl.close
    puts
    puts "Maximum possible common id's: #{common_id.size}"
    common_id.delete_if { |key,val| val.length < (i + 1)}
    puts "After considering file #{i + 1}: #{common_id.size}"
}
puts "--"

puts "Unique common sequences found: #{common_id.size}"
common_id_ary = common_id.values
puts "Intersection contains #{2 * common_id_ary.length}/#{total_line_count} ~ #{((2 * common_id_ary.length * 100000) / Float(total_line_count)).round/Float(1000)}% of total sequences."
ARGV.each_with_index {|filename,i|
    puts " #{common_id_ary.length}/#{individual_line_counts[i]} ~ #{((common_id_ary.length * 100000) / Float(individual_line_counts[i])).round/Float(1000)}% of sequences from #{filename}."
}
puts

common_id_ary.sort! { |i,j| i.qval_tot <=> j.qval_tot}
common_id_ary.flatten!

intsct_filename = "#{ARGV.join("-")}.intsct.csv"
intsct_filehandl = File.open(intsct_filename,"w")
intsct_header = "nolab\tid\tbaseMean\tBaseMeanA\tBaseMeanB\tfoldChange\tlog2foldChange\tpval\tqval"
intsct_filehandl.puts(intsct_header)

puts "writing results to #{intsct_filename}..."
common_id_ary.each { |i|
    pretty_string = "#{i.nolab}\t#{i.id}\t#{i.baseMean}\t#{i.baseMeanA}\t#{i.baseMeanB}\t#{i.foldChange}\t#{i.log2foldChange}\t#{i.pval}\t#{i.qval}"
    intsct_filehandl.puts(pretty_string)
}

intsct_filehandl.close
puts "done."
