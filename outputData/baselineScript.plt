set terminal pdfcairo
set output "baseline.pdf"
set xlabel "List Size"
set ylabel "Number of Ops"
set logscale xy

plot "benchmark_single_thread_core_1.txt" using ($1):($2/3) title "Single Thread" with line,\
 "benchmark_single_thread_core_2.txt" using ($1):($2/3) title "Multi Thread 2" with line,\
 "benchmark_single_thread_core_4.txt" using ($1):($2/3) title "Multi Thread 4" with line, \
 "benchmark_single_thread_core_4.txt" using ($1):($2/3) title "Multi Thread 4" with line

set output "bfl_mutex.pdf"
set xlabel "List Size"
set ylabel "Number of Ops"
set logscale xy

plot "bfl_mutex_thread_1.txt" using ($1):($2/3) title "Single Thread" with line,\
 "bfl_mutex_thread_2.txt" using ($1):($2/3) title "Multi Thread 2" with line,\
 "bfl_mutex_thread_4.txt" using ($1):($2/3) title "Multi Thread 4" with line,\
 "bfl_mutex_thread_16.txt" using ($1):($2/3) title "Multi Thread 16" with line
 
set output "bfl_spin_v_mutex.pdf"
set xlabel "List Size"
set ylabel "Number of Ops"
set logscale xy

plot "bfl_mutex_thread_1_core.txt" using ($1):($2/3) title "Mutex 1" with line,\
 "bfl_mutex_thread_2_core.txt" using ($1):($2/3) title "Mutex 2" with line,\
 "bfl_mutex_thread_4_core.txt" using ($1):($2/3) title "Mutex 4" with line,\
 "bfl_spin_thread_1_core.txt" using ($1):($2/3) title "Spin 1" with line,\
 "bfl_spin_thread_2_core.txt" using ($1):($2/3) title "Spin 2" with line,\
 "bfl_spin_thread_4_core.txt" using ($1):($2/3) title "Spin 4" with line,\
 
set output "bfl_rw.pdf"
set xlabel "List Size"
set ylabel "Number of Ops"
set logscale xy

plot "bfl_rw_thread_900_core.txt" using ($1):($2/3) title "90% Update" with line,\
 "bfl_rw_thread_500_core.txt" using ($1):($2/3) title "50% Update" with line,\
 "bfl_rw_thread_100_core.txt" using ($1):($2/3) title "10% Update" with line

set output "hhl.pdf"
set xlabel "List Size"
set ylabel "Number of Ops"
set logscale xy

plot "bfl_hhl_thread_1.txt" using ($1):($2/3) title "1 Thread" with line,\
 "bfl_hhl_thread_2.txt" using ($1):($2/3) title "2 Threads" with line,\
 "bfl_hhl_thread_3.txt" using ($1):($2/3) title "3 Threads" with line,\
 "bfl_hhl_thread_4.txt" using ($1):($2/3) title "4 Threads" with line,\
 "bfl_hhl_thread_16.txt" using ($1):($2/3) title "16 Threads" with line,\