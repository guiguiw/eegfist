#!/bin/bash

# this script is to be run in the /csv directory after the matlab script has run on all the files. it concatenates the individual csvs into one single csv.

rm all.csv
cat *.csv > all.csv
rm S*
head -1 all.csv | sed 's/[^,]//g' | wc -c
