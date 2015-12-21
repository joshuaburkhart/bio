#!/bin/bash
for f in `cat /media/burkhart/WD_ELEMENTS/reads/list_of_files.txt`;
do
    rsync -azv --partial --progress --append $f /media/burkhart/WD_ELEMENTS/reads/;
done
