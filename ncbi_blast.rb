#!/usr/bin/env ruby

#Usage: ncbi_blast.rb <fasta file with sequences to be blasted against ncbi database>

#Example: ncbi_blast.rb ../exprsn/Contigs_&_Singletons/Singletons.fna

require 'net/http'

TESTING = false
DEBUG = false
NCBI_URI = URI('http://www.ncbi.nlm.nih.gov/blast/Blast.cgi')
BLAST_PG = "tblastx"
Put_Res = Struct.new(:rid,:seq_name)
Format = Struct.new(:web_req_format,:file_suffix)
HTML = Format.new("HTML","html")
TEXT = Format.new("Text","txt")

TEST_SEQ_NAME = "FJP1"
TEST_SEQ = "cagattaaagatctgctggtgagcagcagcaccgatctggataccaccctggtgctggtgaacgcgatttattttaaaggcatgtggaaaaccgcgtttaacgcggaagatacccgcgaaatgccgtttcatgtgaccaaacaggaaagcaaaccggtgcagatgatgtgcatgaacaacagctttaacgtggcgaccctgccggcggaaaaaatgaaaattctggaactgccgtttgcgagcggcgatctgagcatgctggtgctgctgccggatgaagtgagcgatctggaacgcattgaaaaaaccattaactttgaaaaactgaccgaatggaccaacccgaacaccatggaaaaacgccgcgtgaaagtgtatctgccgcagatgaaaattgaagaaaaatataacctgaccagcgtgctgatggcgctgggcatgaccgatctgtttattccgagcgcgaacctgaccggcattagcagcgcggaaagcctgaaaattagccaggcggtgcatggcgcgtttatggaactgagcgaagatggcattgaaatggcgggcagcaccggcgtgattgaagatattaaacatagcccggaaagcgaacagtttcgcgcggatcatccgtttctgtttctgattaaacataacccgaccaacaccattgtgtattttggccgctattggagcccg"



def put(seq_name,seq)
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

    if(put_result.body().match(/RID/))
        if(DEBUG)
            fh = File.open("#{seq_name}.PUT_SUCCESS.html","w")
            fh.puts put_result.body()
            fh.close
        end
        put_result.body().match(/RID = ([0-9A-Z-]+)/)
        rid = $1
        puts "RID: '#{rid}'"
        put_result.body().match(/RTOE = ([0-9]+)/)
        rtoe = $1
        puts "Estimated Request Execution Time: '#{rtoe}' seconds"
        return Put_Res.new(rid,seq_name)
    else
        puts "UNKOWN ERROR OCCURRED FOLLOWING PUT"
        if(DEBUG)
            fh = File.open("#{seq_name}.PUT_ERROR.html","w")
            fh.puts put_result.body()
            fh.close
        end
    end
    return nil
end


def get(format,res)
    get_params = {
        :RID => res.rid,
        :FORMAT_OBJECT => "Alignment",
        :FORMAT_TYPE => format.web_req_format,
        :DESCRIPTIONS => 10,
        :ALIGNMENTS => 10,
        :ALIGNMENT_TYPE => "Pairwise",
        :OVERVIEW => "yes",
        :CMD => "Get",
    }

    NCBI_URI.query = URI.encode_www_form(get_params)
    get_res_body = nil

    act_sec = 0
    begin
        get_result = Net::HTTP.get_response(NCBI_URI)
        if(DEBUG)
            fh = File.open("#{res.seq_name}.GET_SUCCESS.#{format.file_suffix}","w")
            fh.puts get_result.body()
            fh.close
        end
        sleep(3)
        print "..."
        STDOUT.flush
        act_sec += 3
        get_res_body = get_result.body()
    end while(get_res_body.match(/Status=WAITING/))

    puts
    if(get_result.body().match(/Status=READY/))
        puts "Results completed after #{act_sec} seconds"
        fn = "#{res.seq_name}.#{BLAST_PG}.#{format.file_suffix}"
        puts "Writing results to #{fn}..."
        fh = File.open(fn,"w")
        if(format == HTML)
            get_result.body().match(/(<table id="dscTable".*?>.*<\/table>)/m)
            res_table = $1
            linked_table = res_table.gsub(/Blast.cgi/,NCBI_URI.to_s)
            fh.puts linked_table
        else
            get_result.body.match(/(<p>.*?Query=)/m)
            res_header = $1
            res_content = get_result.body().gsub(res_header,'')
            fh.puts "Query ID=#{res.seq_name}\n#{res_content}"
            fh.close
            puts "done."
        end
    else
        puts "UNKNOWN ERROR OCCURRED FOLLOWING GET"
        if(DEBUG)
            fh = File.open("#{res.seq_name}.GET_ERROR.#{format.file_suffix}","w")
            fh.puts get_result.body()
            fh.close
        end
    end
end

res = nil
if(TESTING)
    res = put(TEST_SEQ_NAME,TEST_SEQ)
    get(TEXT,res)
else
    fh = File.open(ARGV[0],"r")
    seq_name = nil
    seq = ""
    seq_count = 0
    while(line = fh.gets)
        if(line.match(/^>(\w*)/))
            next_seq_name = $1
            if(seq_name)
                puts "Performing query with sequence #{seq_count}..."
                res = put(seq_name,seq)
                if(res)
                    get(TEXT,res)
                end
            end
            seq_name = next_seq_name
            seq = ""
            seq_count += 1
        else
            seq += line.strip
        end
    end
    fh.close
end
