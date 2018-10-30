#!/bin/bash

MaxList=1000001
echo "Making program files..."
make all
mkdir outputData
echo "... Done!"


echo "Generating Baseline Data..."
for threads in 1 2 4; do
	       echo "For" $threads "threads"
	       for ((i=1; i<$MaxList; i*=10)) ;do
		   j=$i*2
		   ./benchmark_list_single_thread -i $i -r $j -n $threads -u 0 -d 3000 | awk '/size/{size = $3} /ops/{ops = $2} END{ print size "\t" ops}'
	       done  > outputData/benchmark_single_thread_core_${threads}.txt
done

echo "...Done!"
echo "Generating BFL Mutex..."
for threads in 1 2 4; do
    echo "For" $threads "threads"
    for ((i=1; i<$MaxList; i*=10)) ;do
	j=$i*2
	./benchmark_list_bfl -i $i -r $j -n $threads -u 0 -d 3000 | awk '/size/{size = $3} /ops/{ops = $2} END{ print size "\t" ops}'
    done  > outputData/bfl_mutex_thread_${threads}.txt
done

echo "...Done!"
echo "Generating BFL SpinLock..."
for threads in 1 2 4; do
    echo "For" $threads "threads"
    for ((i=1; i<$MaxList; i*=10)) ;do
	j=$i*2
	taskset -c 0 ./benchmark_list_bfl -i $i -r $j -n $threads -u 0 -d 3000 | awk '/size/{size = $3} /ops/{ops = $2} END{ print size "\t" ops}'
    done  > outputData/bfl_mutex_thread_${threads}_core.txt
done
for threads in 1 2 4; do
    echo "For" $threads "threads"
    for ((i=1; i<$MaxList; i*=10)) ;do
	j=$i*2
	taskset -c 0 ./benchmark_bfl_spin -i $i -r $j -n $threads -u 0 -d 3000 | awk '/size/{size = $3} /ops/{ops = $2} END{ print size "\t" ops}'
    done  > outputData/bfl_spin_thread_${threads}_core.txt
done

echo "...Done!"
echo "Generating Readers Writer Lock..."
for update in 900 500 100; do
    echo "For" $update "update ratio"
    for ((i=1; i<$MaxList; i*=10)) ;do
	j=$i*2
	taskset -c 0 ./benchmark_bfl_rw -i $i -r $j -n 4 -u $update -d 3000  | awk '/size/{size = $3} /ops/{ops = $2} END{ print size "\t" ops}'
    done > outputData/bfl_rw_thread_${update}_core.txt
done
echo "...Done!"
echo "Generating Hand over Hand Lock"
threads=0
for threads in 1 2 3 4; do
    echo "For" $threads "threads"
    for ((i=1; i<$MaxList; i*=10)) ;do
	j=$i*2
	./benchmark_hhl -i $i -r $j -n $threads -d 3000  | awk '/size/{size = $3} /ops/{ops = $2} END{ print size "\t" ops}'
    done > outputData/bfl_hhl_thread_${threads}.txt
done
echo "...Done!"
