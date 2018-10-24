set terminal png
set output "bfl_rw.png"
set xlabel "List Size"
set ylabel "Number of Ops"
set logscale xy
plot "10_multi_thread_rw_core.txt" using ($1):($2/3) title "10% Update" with line,\
 "50_multi_thread_rw_core.txt" using ($1):($2/3) title "50% Update" with line,\
 "90_multi_thread_rw_core.txt" using ($1):($2/3) title "90% Update" with line
