#!/usr/bin/ruby

#Usage: ruby rad_aligner.rb <cut site cohesive end sequence> <cut site sticky end sequence> </path/to/fasta/file/with/rad/tags> </path/to/fasta/file/with/contigs/1> [ ... </path/to/fasta/file/with/contigs/n>]

#Example: ruby rad_aligner.rb C CGTAG ~/tmp/mock_rad_tags.fasta ~/tmp/mock_contigs.fasta

require 'time'

class AssemblyScore
    attr_accessor :name
    attr_accessor :aligned_cut_sites
    attr_accessor :aligned_rad_tags
    attr_accessor :cut_output
    attr_accessor :rad_output
    attr_accessor :rad_mismatches
    def initialize(name)
        @name = name
    end
    def setCutResult(cut_output)
        @cut_output = cut_output
        @cut_output.match(/d (\d+) a/)
        @aligned_cut_sites = Integer($1)
    end
    def setRadResult(rad_output)
        @rad_output = rad_output
        @rad_output.match(/t:\s+(\d+)\s+\(/)
                          @aligned_rad_tags = Integer($1)
                          @rad_mismatches = @rad_output.count(MISMATCH_CHAR)
    end
    def getActOvrExpAlignments
        if (!@aligned_rad_tags.nil? && !@aligned_cut_sites.nil? && @aligned_cut_sites != 0)
            return (1000.0 * @aligned_rad_tags) / (2000.0 * @aligned_cut_sites)
        else
            return -1
        end
    end
    def compareRadTags
        if(!@aligned_rad_tags.nil?)
            return @aligned_rad_tags
        else
            return -1
        end
    end
    def to_s
        alignments = getActOvrExpAlignments()
        if(alignments == -1)
           alignments = "NO CUT SITES ALIGNED TO REFERENCE"
        end
        "FILE NAME: #{@name}\nNUMBER OF CUT SITES ALIGNED: #{@aligned_cut_sites}\nNUMBER OF RAD TAGS ALIGNED: #{@aligned_rad_tags}\nRAD SNP MISMATCHES: #{@rad_mismatches}\nACTUAL / EXPECTED: #{alignments}\n"
    end
    def to_f
        self.to_s +
            "BOWTIE CUT SITE OUTPUT:\n--\n#{@cut_output}--\nBOWTIE RAD TAG OUTPUT:\n--\n#{@rad_output}--\n"
    end
end

##########
# DRIVER #
##########

ce_seq = ARGV[0]
se_seq = ARGV[1]
rad_fasta_file = ARGV[2]

puts "COHESIVE END SEQ: #{ce_seq}"
puts "STICKY END SEQ: #{se_seq}"
puts "RAD FASTA FILE: #{rad_fasta_file}"
puts "ASSEMBLY FILES: "

assembly_scores = Array.new
for i in 3..(ARGV.length - 1)
    puts ARGV[i]
    assembly_scores << AssemblyScore.new(ARGV[i])
end
puts


MISMATCH_CHAR = ">"
BEST = "--best"
ROUT = "--refout"

rad_tags = File.open(rad_fasta_file)
rad_fasta_line = rad_tags.gets
rad_tag_name = "<unknown>"
cut_seq = "#{ce_seq}#{se_seq}"
se_seq_size = se_seq.size
puts "validating RAD tags..."
while(rad_fasta_line)
    print "."
    STDOUT.flush
    if(rad_fasta_line.match(/^>/))
        rad_tag_name = rad_fasta_line
    else
        test_seq = rad_fasta_line[0,se_seq_size]
        if(!test_seq.match(/^[ATCG]/))
            puts "MALFORMED FASTA FILE DETECTED"
            puts "TAG NAME: #{rad_tag_name}"
            exit 1
        elsif(test_seq != se_seq)
            rad_tags.close
            puts "RAD TAG DOES NOT MATCH SPECIFIED CUT SITE"
            puts "TAG NAME: #{rad_tag_name}"
            puts "TAG FIRST #{se_seq_size} BASES: #{test_seq}"
            puts "SPECIFIED CUT SITE SE SEQ: #{se_seq}"
            exit 1
        end
    end
    rad_fasta_line = rad_tags.gets
end
puts "\nRAD tags match"
puts

rad_tags.close

#bowtie args
cut_seq_size = cut_seq.size
MAX_MISMATCHES = 3

puts "aligning sequences to reference(s)..."
assembly_scores.each { |a|
    print "."
    STDOUT.flush
    contigs_fa_file = a.name
    bowtie_idx_name = Time.new.to_f.to_s.sub('.','_')
    sleep(1)
    %x(bowtie-build #{contigs_fa_file} #{bowtie_idx_name})
    a.setCutResult(%x(bowtie -a -n0 -l#{cut_seq_size} -c #{bowtie_idx_name} #{cut_seq} 2>&1))
    a.setRadResult(%x(bowtie #{bowtie_idx_name} -n#{MAX_MISMATCHES} -l#{se_seq_size} #{BEST} -f #{rad_fasta_file} 2>&1))
    %x(rm -f #{bowtie_idx_name}.*)
}
puts "\nsequences aligned"
puts

assembly_scores.sort! { |i,j|
    [j.getActOvrExpAlignments,j.compareRadTags] <=> [i.getActOvrExpAlignments,i.compareRadTags]
}

puts "writing results to file system..."
summary_file = File.open('assembly_score_summaries.txt','w')
summary_file.print "ASSEMBLY SCORE SUMMARIES\n"
summary_file.print "========================\n\n"
summary_file.puts
assembly_scores.each { |a|
    puts
    puts a.to_s
    puts
    summary_file.print a.to_f
    summary_file.puts
}
summary_file.close
puts "finished"
