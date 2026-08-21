CC     = gcc
CFLAGS = -Wall -Wextra -Iinclude

build:
	$(CC) $(CFLAGS) src/Queue.c src/process_generator.c -o process_generator.out
	$(CC) $(CFLAGS) src/clk.c -o clk.out
	$(CC) $(CFLAGS) src/Queue.c src/scheduler.c -lm -o scheduler.out
	$(CC) $(CFLAGS) src/process.c -o process.out
	$(CC) $(CFLAGS) src/test_generator.c -o test_generator.out
	$(CC) $(CFLAGS) src/driverCode_linkedList.c -o driverCode_linkedList.out
	$(CC) $(CFLAGS) src/testMemAlloc.c -lm -o testMemAlloc.out

# Standalone demonstrations of the linked list and the buddy-system allocator
demos: driverCode_linkedList.out testMemAlloc.out

driverCode_linkedList.out: src/driverCode_linkedList.c include/linkedList.h
	$(CC) $(CFLAGS) src/driverCode_linkedList.c -o driverCode_linkedList.out

testMemAlloc.out: src/testMemAlloc.c include/linkedList.h include/headers.h
	$(CC) $(CFLAGS) src/testMemAlloc.c -lm -o testMemAlloc.out

# Only remove build artifacts; never the generated processes.txt input.
clean:
	rm -f *.out

all: clean build

run:
	./process_generator.out
