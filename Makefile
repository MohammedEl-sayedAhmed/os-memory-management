CC     = gcc
CFLAGS = -Wall -Wextra

build:
	$(CC) $(CFLAGS) Queue.c process_generator.c -o process_generator.out
	$(CC) $(CFLAGS) clk.c -o clk.out
	$(CC) $(CFLAGS) Queue.c scheduler.c -lm -o scheduler.out
	$(CC) $(CFLAGS) process.c -o process.out
	$(CC) $(CFLAGS) test_generator.c -o test_generator.out
	$(CC) $(CFLAGS) driverCode_linkedList.c -o driverCode_linkedList.out
	$(CC) $(CFLAGS) testMemAlloc.c -lm -o testMemAlloc.out

# Standalone demonstrations of the linked list and the buddy-system allocator
demos: driverCode_linkedList.out testMemAlloc.out

driverCode_linkedList.out: driverCode_linkedList.c linkedList.h
	$(CC) $(CFLAGS) driverCode_linkedList.c -o driverCode_linkedList.out

testMemAlloc.out: testMemAlloc.c linkedList.h headers.h
	$(CC) $(CFLAGS) testMemAlloc.c -lm -o testMemAlloc.out

# Only remove build artifacts; never the generated processes.txt input.
clean:
	rm -f *.out

all: clean build

run:
	./process_generator.out
