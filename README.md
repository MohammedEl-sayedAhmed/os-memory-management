# OS Memory Management

A process scheduler coupled with a buddy-system memory allocator, built on top of System V IPC as an operating-systems course project.

This is **Phase 2** of the project. It extends the scheduler from **Phase 1** with dynamic memory management: every process now requests a block of memory on arrival, the memory is allocated with a buddy system, and it is freed (and coalesced) when the process finishes. Phase 1 (the scheduler on its own) lives in a separate repository: [OS-Scheduler](https://github.com/MohammedEl-sayedAhmed/OS-Scheduler).

## Overview

The system emulates an operating system that:

1. Reads a set of processes (with arrival time, run time, priority, and memory size) from an input file.
2. Emulates a system clock and releases each process to the scheduler at its arrival time.
3. Schedules the processes on a single CPU using one of three algorithms.
4. Allocates and frees memory for each process using a buddy-system allocator.
5. Logs every scheduling and memory event and computes end-of-run performance statistics.

The processes, the clock, and the scheduler run as separate cooperating Linux processes that communicate through System V IPC.

## Scheduling algorithms

The scheduler supports three algorithms, chosen interactively at start-up:

- **HPF — Highest Priority First (non-preemptive):** the ready process with the best priority runs to completion before the next one is picked.
- **SRTN — Shortest Remaining Time Next (preemptive):** whenever a process arrives with a shorter remaining time than the running one, the CPU is preempted in its favour.
- **RR — Round Robin (preemptive, quantum-based):** each process runs for at most a fixed time quantum before being moved to the back of the ready queue. The quantum is entered by the user when RR is selected.

## Memory management

Memory is managed with a **buddy-system allocator** over a fixed memory space (1024 bytes, chunks from 8 up to 1024 bytes across 8 free lists).

- On allocation, the request is rounded up to the nearest power-of-two chunk. If no chunk of the needed size is free, a larger chunk is split recursively until a chunk of the right size becomes available.
- On deallocation, the freed chunk is returned to its free list and merged with its buddy whenever the buddy is also free, coalescing recursively into larger chunks.

The free lists are kept as sorted linked lists (`linkedList.h`). Each allocation and free is recorded in the memory log with the time, size, process id, and the byte range occupied.

## Architecture and IPC

The project is Linux-specific and relies on the System V IPC facilities:

- **Shared memory** — an emulated system clock. `clk.c` creates a one-integer shared-memory segment (key `SHKEY`, `300`) and increments it once per second; every other process attaches to it to read the current time.
- **Message queues** — the process generator sends each process control block (PCB) to the scheduler through a message queue (key `13245`) at the process's arrival time. A sentinel PCB signals that no further processes will arrive.
- **Signals** — `SIGUSR1` is raised by a running process to notify the scheduler that it has finished; `SIGSTOP` / `SIGCONT` preempt and resume processes; `SIGINT` triggers cleanup of all IPC resources on shutdown.

The four cooperating programs are:

- `process_generator.c` — reads the input file, creates the clock and scheduler, and feeds processes to the scheduler at their arrival times.
- `clk.c` — the emulated clock (provided by the course; not meant to be modified).
- `scheduler.c` — the scheduler plus the buddy-system allocator and all logging/statistics.
- `process.c` — a single scheduled process that counts down its run time against the emulated clock.

Because it uses System V IPC and POSIX signals, the project must be built and run on **Linux**.

## Input format

Processes are read from `processes.txt`. Lines beginning with `#` are comments. Each remaining line describes one process as five whitespace-separated integer columns:

```
#id arrival runtime priority memory_size
1	1	2	4	108
2	6	28	6	18
3	9	23	1	60
```

| Column | Meaning |
| --- | --- |
| `id` | process identifier |
| `arrival` | arrival time (in clock ticks) |
| `runtime` | required CPU time |
| `priority` | scheduling priority (lower value = higher priority) |
| `memory_size` | requested memory in bytes |

`test_generator.c` builds this file for you: it prompts for a process count and writes randomly generated processes in the format above.

## Build and run

Requires `gcc` and `make` on Linux.

```sh
make build     # compile all programs
make run       # start the simulation (runs ./process_generator.out)
```

`make build` compiles the four core programs, the `test_generator` helper, and the two stand-alone demos (`driverCode_linkedList.out`, the linked-list driver, and `testMemAlloc.out`, the buddy-allocator demo). `make clean` removes the compiled `*.out` binaries. `make all` runs `clean` followed by `build`.

Before running the simulation, generate an input file (for example with `./test_generator.out`) or edit `processes.txt` by hand. When you run `make run`, the program asks for a scheduling algorithm (`HPF`, `SRTN`, or `RR`) and, for `RR`, a quantum.

## Output

Running the simulation produces:

- `SchedulerLog.txt` — every start / stop / resume / finish event with per-process timing.
- `SchedulerCalc.txt` — end-of-run statistics (CPU utilisation, average weighted turnaround time, average waiting time, standard deviation of weighted turnaround time).
- `MemoryLog.txt` — every allocation and free, with time, size, process id, and byte range.

These files, along with the compiled `*.out` binaries and any generated `processes.txt`, are regenerated on each run and are not tracked at the repository root. A captured sample run is kept as reference evidence in [`examples/sample-output/`](examples/sample-output/) — `scheduler.log`, `metrics.txt`, and `memory.log`.

## Repository layout

| File | Role |
| --- | --- |
| `process_generator.c` | reads input, spawns clock and scheduler, feeds processes |
| `scheduler.c` | HPF / SRTN / RR scheduling + buddy-system allocator + logging |
| `process.c` | a single scheduled process |
| `clk.c` | emulated system clock (provided) |
| `test_generator.c` | random `processes.txt` generator |
| `headers.h` | shared IPC helpers (clock, message queue, send/receive) |
| `PCB.h` | process control block definition and helpers |
| `Queue.h` / `Queue.c` | FIFO queue used by the generator and RR |
| `PriorityQueue.h` | priority queue used by HPF / SRTN |
| `linkedList.h` | sorted linked list backing the buddy free lists |
| `driverCode_linkedList.c` | stand-alone linked-list demo |
| `testMemAlloc.c` | stand-alone buddy-allocator demo |
| `OS_Memory.pdf` | assignment specification |

## Authors

- Mohammed El-sayed Ahmed
- Nadine-Amr
- Rahma2015
- TasneemOmara
