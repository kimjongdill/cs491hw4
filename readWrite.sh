#!/bin/bash
for k in 90 50 10
do
    echo $k
	 for i in {1..1000001..10000};do
		  j=$i*2
		  ./benchmark_bfl_rw -i $i -r $j -u $k -n 4 -d 3000 | awk '/size/{size = $3} /ops/{ops = $2} END{ print size "\t" ops}'
	       done > ${k}_multi_thread_rw_core.txt
   done
		  
