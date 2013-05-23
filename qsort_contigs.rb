#!/usr/bin/ruby

out_dir = "\
/home11/mmiller/Wyeomyia/output/queue_out/
"

orig_contigs_file = "\
/home11/mmiller/Wyeomyia/output/velvet_out/velvet-wy_unfiltered_combined_reads_diginorm_paired.fastq.keep_k\=31_e\=19/contigs.fa\
"

puts orig_contigs_file

loc_dir = "\
/scratch/$USER/\\$PBS_JOBID/\
"

puts loc_dir

loc_contigs_file = "\
#{loc_dir}/contigs.fa\
"

puts loc_contigs_file

dir_setup = "\
mkdir -p #{loc_dir} && \
cp #{orig_contigs_file} #{loc_contigs_file}\
"

puts dir_setup

dir_teardown = "\
rm -f #{loc_contigs_file}\
"

modules = "\
ruby\
"

prog = "\
ruby /home13/jburkhar/software_projects/bio/sort_contigs.rb\
"

args = "\
 -f #{loc_contigs_file}\
 -s 5\
 -o #{loc_dir}\
"
print "Locating capable node..."
avail_nodes = []
num_minutes = 0 
selected_node = 0 
while(avail_nodes.length == 0)
    avail_nodes = %x((echo ! && qnodes) | tr '\n' '!' | grep -Po '(?<=!)\s*fn[2-8]+(?=\s*!\s*state = [^!]*free[^!]*!)').split(/\n/)
    if(avail_nodes.length == 0)
        print "." 
        STDOUT.flush
        sleep(60)
        num_minutes += 1
    else
        selected_node = srand() % avail_nodes.length
        print "Assigned node #{avail_nodes[selected_node]} after #{num_minutes} minute wait."
        STDOUT.flush
    end 
end
puts

submit_args = "\
 -m #{modules}\
 -q longfat\
 -n #{avail_nodes[selected_node]}\
 \"\
 #{dir_setup}\
 &&\
 #{prog}\
 #{args}\
 &&\
 #{dir_teardown}\
 \"\
"

stdout = %x(qsubmit.rb #{submit_args})
puts "#{stdout}"
