set terminal png
set output "bfl.png"
set xlabel "List Size"
set ylabel "Number of Ops"
set logscale xy
plot "single_thread_bfl.txt" using ($1):($2/3) title "Single Thread" with line,\
 "multi_thread_bfl.txt" using ($1):($2/3) title "Multi Thread 4" with line,\
 "multi_thread_bfl_2.txt" using ($1):($2/3) title "Multi Thread 2" with line
