#USAGE:
#./rq.sh <name of file to execute with arguments> <queue name> <job name> <cores> <node name>  
#
#EXAMPLE:
#./rq.sh "/home13/jburkhar/N-Body/mpinbody_no -DT 86548 -T 364 -G 6.67E-12 -f /home13/jburkhar/N-Body/galaxy.dat" fatnodes N-Body 32 un8
#
#Note: the name of the file to execute and the command line arguments must be surrounded by quotes ("") so they can be accepted as a single parameter to this script

echo "#!/bin/bash -l
#PBS -N ${3:-'jburkhart_default_jobname'}
#PBS -o /home13/jburkhar/research/out/queue_out/
#PBS -e /home13/jburkhar/research/out/queue_out/
#PBS -d /home13/jburkhar/research/out/queue_out/
#PBS -l nodes=${5:-'1'}:ppn=${4:-'12'}
#PBS -q ${2:-'fatnodes'}

# or create scratch directory in /tmp, if applicable:
rm -rfv /tmp/$USER; mkdir -v /tmp/$USER

# Load any modules needed to run your software
module load stacks
module load velvet

# the following lines are not required, but can be useful 
# for debugging purposes:
#diplays PBS work directory
#echo "PBS_O_WORKDIR:" $PBS_O_WORKDIR
#cd $PBS_O_WORKDIR

#displays nodefile and contents of nodefile, useful for running MPI
#echo "PBS_NODEFILE:" $PBS_NODEFILE
#cat $PBS_NODEFILE > hostfile.tmp

#displays PBS jobname and jobid
#echo "PBS_JOBNAME, PBS_JOBID:" $PBS_JOBNAME $PBS_JOBID

#displays username and hostname, 
#export USER_NAME=`whoami`
#export HOST_NAME=`hostname -s`
#echo "Hello from $USER_NAME at $HOST_NAME"

#make sure we are running the MPI version we want:
#which mpirun

# execute program here:
$1 

# copy data from scratch (or tmp) directory back to home directory for long term storage:
/bin/cp -a /tmp/$USER/* $HOME/research/out/

# clean up after ourselves so others can utilize scratch:
/bin/rm -rf /tmp/$USER

" > ~/tmp_pbs.sh
qsub ~/tmp_pbs.sh
rm ~/tmp_pbs.sh
