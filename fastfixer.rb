#!/usr/bin/ruby

require 'optparse'

options ={}
optparse = OptionParser.new { |opts|
    opts.banner = <<-EOS
Usage: fastfixer.rb -t <task> -q <path/to/fastq/filename> -i <sequence identifier>

Example: fastfixer.rb -t q2a -q wy_sample.fastq -i @HWI-ST0747
    EOS
    opts.on('-h','--help','Display this screen'){
        puts opts
        exit
    }
    options[:seq_id] = nil
    opts.on('-i','--id SEQ_ID','Identifier for fastq sequences SEQ_ID') { |seq_id|
        options[:seq_id] = seq_id
    }
    options[:fastq] = nil
    opts.on('-q','--fastq FILE1,FILE2,FILEN',Array,'The fastq input files') { |fastq_files|
        options[:fastq] = fastq_files
    }
    options[:fasta] = nil
    opts.on('-a','--fasta FILE1,FILE2,FILEN',Array,'The fasta input files') { |fasta_files|
        options[:fasta] = fasta_files
    }
    options[:out_dir] = "./"
    opts.on('-o','--out OUT_DIR','Directory for output OUT_DIR') { |out_dir|
        if(File.exists? out_dir)
            if(!File.directory? out_dir)
                out_dir = "#{out_dir}_dir"
            end 
        else
            %x(mkdir -p #{out_dir})
        end 
        options[:out_dir] = out_dir
    }
    options[:task] = nil
    opts.on('-t','--task T_ID',[:q2a, :fastq2fasta, :a2q, :fasta2fastq, :fns, :filterNs, :fqs, :filterqualityscores],'Task to be performed. One of q2a, a2q, fns, fqs') { |t_id|
        options[:task] = t_id
    }
    options[:p] = false
    opts.on('-p','--paired','Input is paired') {
        options[:p] = true
    }
    options[:w] = nil
    opts.on('-w','--fastq_end1 FILE','End 1 of PE fastq reads') { |file|
        options[:w] = file
    }
    options[:e] = nil
    opts.on('-e','--fastq_end2 FILE','End 2 of PE fastq reads') { |file|
        options[:e] = file
    }
    options[:s] = nil
    opts.on('-s','--fasta_end1 FILE','End 1 of PE fasta reads') { |file|
        options[:s] = file
    }
    options[:d] = nil
    opts.on('-d','--fasta_end2 FILE','End 2 of PE fasta reads') { |file|
        options[:d] = file
    }
}

optparse.parse!

if(options[:task].nil?)
    puts "Specify '-h' for help..."
    raise OptionParser::MissingArgument, "task = \'#{options[:task]}\'"
end

if(options[:p] && (!(!options[:w].nil? && !options[:e].nil?) && !(!options[:s].nil? && !options[:d].nil?)))
    puts "Must specify both ends of paired input"
    exit
elsif(options[:p].nil? && options[:fastq].nil? && options[:fasta].nil?)
    puts "Must specify input file(s)"
    exit
end

def printError(line_num,exp_format,line)
    puts "LINE #{line_num} INCORRECTLY FORMATTED:"
    puts "Expected: #{exp_format}"
    puts "Actual: '#{line}'"
    return false
end

def parseOutFilename(in_filename,suffix,out_dir)
    in_filename.match(/^.*?([\w_-]+?)\.\w+$/)
    out_filename = "#{out_dir}/#{$1}-#{suffix}"
    return out_filename
end

def openOutFilehandl(out_filename)
    out_filehandl = File.open(out_filename,"w")
    return out_filehandl
end

case
when(options[:task] == :q2a || options[:task] == :fastq2fasta)
    if(!options[:fasta].nil?)
        options[:fasta].each { |fasta_filename|
            %x(cp #{fasta_filename} #{options[:out_dir]}/#{fasta_filename} 2>&1)
        }
    end
    if(!options[:fastq].nil?)
        options[:fastq].each { |fastq_filename|
            output_fasta_filename = parseOutFilename(fastq_filename,"fastq2.fasta",options[:out_dir])
            output_fasta_filehandl = openOutFilehandl(output_fasta_filename)

            line_num = 0
            valid = true

            File.open(fastq_filename,"r") { |fastq_filehandl|
                while fastq_file_line = fastq_filehandl.gets

                    line_num += 1
                    sequence_id = fastq_file_line
                    if(options[:seq_id].nil?)
                        print "SEQUENCE ID NOT SPECIFIED..."
                        if(sequence_id.match(/^(@.+?):.*$/))
                            puts "USING #{$1}"
                            options[:seq_id] = $1
                        else
                            puts "UNABLE TO FIND VALID SEQUENCE ID"
                            raise OptionParser::MissingArgument, "sequence id = \'#{options[:seq_id]}\'"
                        end
                    end
                    valid = sequence_id.match(/^#{options[:seq_id]}.*$/) ? (valid && true) : printError(line_num,"^#{options[:seq_id]}.*$",fastq_file_line)

                    line_num += 1
                    bases = fastq_file_line = fastq_filehandl.gets
                    valid = bases.match(/^[ATCGN]+$/) ? (valid && true) : printError(line_num,"^[ATCGN]+$",fastq_file_line)

                    line_num += 1
                    plus = fastq_file_line = fastq_filehandl.gets
                    valid = plus.match(/^\+.*$/) ? (valid && true) : printError(line_num,"^\+.*$",fastq_file_line)

                    line_num += 1
                    quality_score = fastq_file_line = fastq_filehandl.gets

                    if(valid)
                        output_fasta_filehandl.print ">#{sequence_id}"
                        output_fasta_filehandl.print bases
                    else 
                        puts "Aborting..."
                        output_fasta_filehandl.close
                        %x(rm -f #{output_fasta_filename})
                        exit
                    end
                end
                output_fasta_filehandl.puts
                output_fasta_filehandl.close
                fastq_filehandl.close
            }
        }
    end
when(options[:task] == :a2q || options[:task] == :fasta2fastq)
    #TODO
    #implement a2q
when(options[:task] == :fns || options[:task] == :filterNs)
    #TODO
    #implement for se fasta, se fastq, and pe fasta files
    if(options[:p])
        if(!options[:w].nil? && !options[:e].nil?)
            fastq_1_filename = options[:w]
            fastq_2_filename = options[:e]
            output_fastq_1_filename = parseOutFilename(fastq_1_filename,"fns.fastq",options[:out_dir])
            output_fastq_2_filename = parseOutFilename(fastq_2_filename,"fns.fastq",options[:out_dir])
            output_fastq_1_filehandl = openOutFilehandl(output_fastq_1_filename)
            output_fastq_2_filehandl = openOutFilehandl(output_fastq_2_filename)

            line_num = 0

            fastq_1_filehandl = File.open(fastq_1_filename,"r")
            fastq_2_filehandl = File.open(fastq_2_filename,"r")
            while fastq_1_file_line = fastq_1_filehandl.gets
                fastq_2_file_line = fastq_2_filehandl.gets

                valid = true
                line_num += 1

                if(!fastq_1_file_line.match(/^\s+$/) && !fastq_2_file_line.match(/^\s+$/))
                    sequence_id_1 = fastq_1_file_line
                    sequence_id_2 = fastq_2_file_line
                    if(options[:seq_id].nil?)
                        print "SEQUENCE ID NOT SPECIFIED..."
                        if(sequence_id_1.match(/^(@.+?):.*$/))
                            puts "USING #{$1}"
                            options[:seq_id] = $1
                        else
                            puts "UNABLE TO FIND VALID SEQUENCE ID"
                            raise OptionParser::MissingArgument, "sequence id = \'#{options[:seq_id]}\'"
                        end
                    end
                    valid = sequence_id_1.match(/^#{options[:seq_id]}.*$/) ? (valid && true) : printError(line_num,"^#{options[:seq_id]}.*$",fastq_1_file_line)
                    valid = sequence_id_2.match(/^#{options[:seq_id]}.*$/) ? (valid && true) : printError(line_num,"^#{options[:seq_id]}.*$",fastq_2_file_line)

                    line_num += 1
                    bases_1 = fastq_1_file_line = fastq_1_filehandl.gets
                    bases_2 = fastq_2_file_line = fastq_2_filehandl.gets
                    all_called_1 = bases_1.match(/^[ATCG]+$/)
                    all_called_2 = bases_2.match(/^[ATCG]+$/)
                    valid = all_called_1 ? (valid && true) : printError(line_num,"^[ATCG]+$",fastq_1_file_line)
                    valid = all_called_2 ? (valid && true) : printError(line_num,"^[ATCG]+$",fastq_2_file_line)
                    all_called = (all_called_1 && all_called_2)

                    line_num += 1
                    plus_1 = fastq_1_file_line = fastq_1_filehandl.gets
                    plus_2 = fastq_2_file_line = fastq_2_filehandl.gets
                    valid = plus_1.match(/^\+.*$/) ? (valid && true) : printError(line_num,"^\+.*$",fastq_1_file_line)
                    valid = plus_2.match(/^\+.*$/) ? (valid && true) : printError(line_num,"^\+.*$",fastq_2_file_line)

                    line_num += 1
                    quality_score_1 = fastq_1_file_line = fastq_1_filehandl.gets
                    quality_score_2 = fastq_2_file_line = fastq_2_filehandl.gets
                    if(valid && all_called)
                        output_fastq_1_filehandl.print ">#{sequence_id_1}"
                        output_fastq_2_filehandl.print ">#{sequence_id_2}"
                        output_fastq_1_filehandl.print bases_1
                        output_fastq_2_filehandl.print bases_2
                        output_fastq_1_filehandl.print plus_1
                        output_fastq_2_filehandl.print plus_2
                        output_fastq_1_filehandl.print quality_score_1
                        output_fastq_2_filehandl.print quality_score_2
                    elsif(!all_called)
                        #TODO
                        #write reads with uncalled bases to separate file
                    else 
                        puts "Aborting..."
                        output_fastq_1_filehandl.close
                        output_fastq_2_filehandl.close
                        %x(rm -f #{output_fastq_1_filename})
                        %x(rm -f #{output_fastq_2_filename})
                        fastq_1_filehandl.close
                        fastq_2_filehandl.close
                        exit
                    end
                end
            end

            output_fastq_1_filehandl.puts
            output_fastq_2_filehandl.puts
            output_fastq_1_filehandl.close
            output_fastq_2_filehandl.close
            fastq_1_filehandl.close
            fastq_2_filehandl.close
        end
    end
when(options[:task] == :fqs || options[:task] == :filterqualityscores)
    #TODO
    #implement fqs
else
    puts "UNRECOGNIZED TASK: '#{options[:task]}' SPECIFIED"
end

