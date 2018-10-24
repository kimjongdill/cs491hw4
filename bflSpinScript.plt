set terminal png
set output "bfl_spin.png"
set xlabel "List Size"
set ylabel "Number of Ops"
set logscale xy
plot "single_thread_bfl_spin.txt" using ($1):($2/3) title "Single Thread Spin" with line,\
 "multi_thread_bfl_spin.txt" using ($1):($2/3) title "Multi Thread 4 Spin" with line,\
 "multi_thread_bfl_spin_2.txt" using ($1):($2/3) title "Multi Thread 2 Spin" with line,\
 "single_thread_bfl_core.txt" using ($1):($2/3) title "Single Thread Mutex" with line,\
 "multi_thread_bfl_core.txt" using ($1):($2/3) title "Multi Thread 4 Mutex" with line,\
 "multi_thread_bfl_2_core.txt" using ($1):($2/3) title "Multi Thread 2 Mutex" with line
