#!/usr/local/packages/ruby/1.9.3-p194/bin/ruby

#Usage: ncbi_blast.rb <fasta file with sequences to be blasted against ncbi database>

#Example:

require 'net/http'

NCBI_URI = URI('http://www.ncbi.nlm.nih.gov')
BLAST_PG = "tblastx"

seq_name = "FJP1"
seq = "atgcatgcttatgcatgctgca"

seq_count = 1
puts "Performing query with sequence #{seq_count}..."
put_params = {
    :QUERY => seq,
    :DATABASE => "nr",
    :HITLIST_SIZE => 10,
    :FILTER => 'L',
    :EXPECT => 10,
    :FORMAT_TYPE => "HTML",
    :PROGRAM => BLAST_PG,
    :CLIENT => "web",
    :SERVICE => "plain",
    :NCBI_GI => "on",
    :PAGE => "Nucleotides",
    :CMD => "Put", 
}
NCBI_URI.query = URI.encode_www_form(put_params)
put_result = Net::HTTP.get_response(NCBI_URI)

put_result.body().match(/RID = ([0-9-]+)/)
rid = $1
puts "RID: '#{rid}'"
put_result.body().match(/RTOE = ([0-9]+)/)
rtoe = $1
puts "Estimated Request Execution Time: '#{rtoe}' seconds"

get_params = {
    :RID => rid,
    :FORMAT_OBJECT => "Alignment",
    :FORMAT_TYPE => "HTML",
    :DESCRIPTIONS => 10,
    :ALIGNMENTS => 10,
    :ALIGNMENT_TYPE => "Pairwise",
    :OVERVIEW => "yes",
    :CMD => "Get",
}

NCBI_URI.query = URI.encode_www_form(get_params)
get_result = Net::HTTP.get_response(NCBI_URI)

act_sec = 0
while(get_result.body().match(/Status=WAITING/))
    sleep(3)
    print "..."
    STDOUT.flush
    act_sec += 3
end

puts
if(get_result.body().match(/Status=READY/))
    puts "Results completed after #{act_sec} seconds"
    fh = File.open("#{seq_name}.#{BLAST_PG}.html","w")
    fh.puts get_result.body()
    fh.close
else
    puts "UNKNOWN ERROR OCCURRED"
    fh = File.open("#{seq_name}.ERROR.html","w")
    fh.puts get_result.body()
    fh.close
end


