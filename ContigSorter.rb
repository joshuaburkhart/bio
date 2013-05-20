
class ContigSorter

    def initialize(comp,ex_id,dir)
        @file_count = 0
        @comp = comp
        @ex_id = ex_id
        @contigs_filename = "#{dir}/#{ex_id}"
    end

    def sort()
        sort(contigs_filename)
    end

    def getFileCount()
        @file_count += 1
        return @file_count
    end

    def compSize(e1,e2)
        return @comp == 1 ? (e1 > e2) : (e1 < e2)
    end

    def sortFile(filename)
        if(containsMinContigs(filename,2))
            filename_L = "#{@contigs_filename}_L_#{getFileCount()}"
            filename_R = "#{@contigs_filename}_R_#{getFileCount()}"
            contig_counter = 0
            while(nextContig = popTopContig(filename))
                if(contig_counter % 2 == 0)
                    append(filename_L,nextContig)
                else
                    append(filename_R,nextContig)
                end
                contig_counter += 1
            end

            filename_L = sortFile(filename_L)
            filename_R = sortFile(filename_R)

            filename_M = "#{@contigs_filename}_M_#{getFileCount()}"
            return mergeFiles(filename_L,filename_R,filename_M)
        else
            return filename
        end
    end

    def mergeFiles(filename_L, filename_R, filename_M)
        while(containsMinContigs(filename_L,1) || containsMinContigs(filename_R,1))
            if(containsMinContigs(filename_L,1) && containsMinContigs(filename_R,1))
                length_L = getTopContigLength(filename_L)
                length_R = getTopContigLength(filename_R)
                firstContig = compSize(length_L,length_R) ? popTopContig(filename_L) : popTopContig(filename_R)
                append(filename_M,firstContig)
            elsif(containsMinContigs(filename_L,1))
                append(filename_M,popTopContig(filename_L))
            elsif(containsMinContigs(filename_R,1))
                append(filename_M,popTopContig(filename_R))
            else
                puts "unkown error..."
                exit(1)
            end
        end
        return filename_M
    end

    def containsMinContigs(filename, min_limit)
        contig_count = 0
        if(File.exist?(filename))
            filehandl = File.open(filename,"r")
            while((line = filehandl.gets) && contig_count < min_limit)
                if(line.match(/^>/))
                    contig_count += 1
                end
            end
            filehandl.close
        end
        return contig_count >= min_limit
    end

    def getTopContigLength(filename)
        filehandl = File.open(filename,"r")
        length = 0
        contig_label = filehandl.gets
        if(contig_label.match(/^>/))
            while(line = filehandl.gets)
               if(line.match(/(^[ATCGNatcgn]*\n?$)/))
                length += line.count("ATCGNatcgn")
               else
                   break
               end
            end
        else
            return nil
        end
        filehandl.close
        return length
    end

    def popTopContig(filename)
        cp_filename = "#{filename}.tmp"
        filehandl = File.open(filename,"r")
        topContig = nil
        orig_contig_label = filehandl.gets
        if(orig_contig_label.match(/^>/))
            orig_topContig = orig_contig_label
            cp_buf = nil
            while(orig_line = filehandl.gets)
                if(orig_line.match(/(^[ATCGNatcgn]*\n?$)/))
                    orig_topContig = "#{orig_topContig}#{orig_line}"
                else
                    cp_buf = orig_line
                    break
                end
            end
            cp_filehandl = File.open(cp_filename,"w")
            cp_filehandl.puts(cp_buf)
            while(orig_line = filehandl.gets)
                cp_filehandl.puts(orig_line)
            end
            filehandl.close
            cp_filehandl.close
            File.delete(filename)
            File.rename(cp_filename,filename)
        else
            filehandl.close
            return nil
        end
        return orig_topContig
    end

    def append(filename, contig)
        filehandl = File.open(filename,"a")
        filehandl.puts(contig)
        filehandl.close
    end

    def cpTopContigs(filename,cp_filename,lim)
        filehandl = File.open(filename,"r")
        cp_filehandl = File.open(cp_filename,"w")
        count = 0
        contig_label = filehandl.gets
        contigs = ""
        if(contig_label.match(/^>/))
            contig_buf = contig_label
            begin
                contig_line = filehandl.gets
                if(contig_line.nil?)
                    contigs = "#{contigs}#{contig_buf}"
                    contig_buf = contig_line
                    break
                elsif(contig_line.match(/^>/))
                    count += 1
                    contigs = "#{contigs}#{contig_buf}"
                    contig_buf = contig_line
                elsif(contig_line.match(/^[ATCGNatcgn]*\n?$/))
                    contig_buf = "#{contig_buf}#{contig_line}"
                else
                    filehandl.close
                    cp_filehandl.close
                    puts "wtf malformed contig line '#{contig_line}' detected"
                    exit(1)
                end
            end while(count < lim)
            cp_filehandl.puts(contigs)
        else
            filehandl.close
            cp_filehandl.close
            puts "wtf malformed contig label '#{contig_label}' detected"
            exit(1)
        end
        filehandl.close
        cp_filehandl.close
    end
end
