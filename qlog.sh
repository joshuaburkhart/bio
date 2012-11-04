#!/bin/bash

clear

exit_funct()
{
  echo "Exiting..."
  rm -f $TMP_FILE_1
  rm -f $TMP_FILE_2
  exit 0
}

TMP_FILE_1=$(date +%s | shasum | tr ' -' 'X')
touch $TMP_FILE_1
sleep 1
TMP_FILE_2=$(date +%s | shasum | tr ' -' 'X')
touch $TMP_FILE_2

trap exit_funct SIGINT

echo "Current Jobs:"
qstat -n | grep jburkhar | awk '{$5=""; $10=""; $11=""; print $0}' > $TMP_FILE_1
cat $TMP_FILE_1
cat $TMP_FILE_1 > $TMP_FILE_2

echo ""
echo "Activity:"

while true
do

  qstat -n | grep jburkhar | awk '{$5=""; $10=""; $11=""; print $0}' > $TMP_FILE_1
  diff $TMP_FILE_1 $TMP_FILE_2 | awk '{if($1==">"){$1="<<FINISHD>>"; print d, $0;} else if($1=="<"){$1="<<STARTED>>"; print d, $0;}}' "d=$(date)"
  cat $TMP_FILE_1 > $TMP_FILE_2
  sleep 5

done

