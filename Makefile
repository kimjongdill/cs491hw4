CC := gcc
LD := gcc

ROOT ?= ../..

MAKE := make
FFWD_DIR=$(ROOT)/../../codes
NPROC=$(shell nproc)

CFLAGS += -g -Wall -Winline $(LDLIB)
CFLAGS += -O3 -DT$(NPROC)

LDFLAGS += -lpthread -lnuma -DT$(NPROC)

.PHONY: all clean

BINS = benchmark_list_single_thread test_list_single_thread benchmark_list_bfl test_list_bfl benchmark_bfl_spin test_bfl_spin benchmark_bfl_rw test_bfl_rw benchmark_hhl test_hhl

all: $(BINS)

benchmark_list.o: benchmark_list.c benchmark_list.h
	$(CC) $(CFLAGS) -c -o $@ $<

test_list.o: test_list.c benchmark_list.h
	$(CC) $(CFLAGS) -c -o $@ $<

list_single_thread.o: list_single_thread.c benchmark_list.h 
	$(CC) $(CFLAGS) -c -o $@ $<

list_bfl.o: list_bfl.c benchmark_list.h 
	$(CC) $(CFLAGS) -DMUTEX -c -o $@ $<

list_bfl_spin.o: list_bfl.c benchmark_list.h
	$(CC) $(CFLAGS) -DSPIN -c -o $@ $<

list_bfl_rw.o: list_bfl.c benchmark_list.h
	$(CC) $(CFLAGS) -DRW -c -o $@ $<

list_hhl.o: hhl.c benchmark_list.h
	$(CC) $(CFLAGS) -c -o $@ $<

benchmark_list_single_thread: benchmark_list.o list_single_thread.o 
	$(LD) $(LDLIB) -o $@ $^ $(LDFLAGS)

benchmark_list_bfl: benchmark_list.o list_bfl.o 
	$(LD) $(LDLIB) -o $@ $^ $(LDFLAGS)

benchmark_bfl_spin: benchmark_list.o list_bfl_spin.o
	$(LD) $(LDLIB) -o $@ $^ $(LDFLAGS)

benchmark_bfl_rw: benchmark_list.o list_bfl_rw.o
	$(LD) $(LDLIB) -o $@ $^ $(LDFLAGS)

benchmark_hhl: benchmark_list.o list_hhl.o
	$(LD) $(LDLIB) -o $@ $^ $(LDFLAGS)

test_list_single_thread: test_list.o list_single_thread.o 
	$(LD) $(LDLIB) -o $@ $^ $(LDFLAGS)

test_list_bfl: test_list.o list_bfl.o 
	$(LD) $(LDLIB) -o $@ $^ $(LDFLAGS)

test_bfl_spin: test_list.o list_bfl_spin.o
	$(LD) $(LDLIB) -o $@ $^ $(LDFLAGS)

test_bfl_rw: test_list.o list_bfl_rw.o
	$(LD) $(LDLIB) -o $@ $^ $(LDFLAGS)

test_hhl: test_list.o list_hhl.o
	$(LD) $(LDLIB) -o $@ $^ $(LDFLAGS)

tree_single_thread.o: tree_single_thread.c
	$(CC) $(CFLAGS) -c -o $@ $<

benchmark_tree_single_thread: tree_single_thread.o benchmark_list.o
	$(LD) $(LDLIB) -o $@ $^ $(LDFLAGS)

report.pdf: report.tex
	pdflatex report.tex
	pdflatex report.tex

clean:
	rm -f $(BINS) *.o *.so
