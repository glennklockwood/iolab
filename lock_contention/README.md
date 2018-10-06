Effects of Lock Contention
==========================

This experiment demonstrates the performance difference between a shared-file
write workload that was performed with writes aligned on specific boundaries
(e.g., every write starts on a 1 MiB offset) and writes performed without any
alignment.

Data is generated from a set of IOR runs that use the HDF5 API.  Because HDF5
includes small metadata headers before each dataset, it is prone to performing
slightly misaligned I/Os unless `H5Pset_alignment()` is explicitly used.  Each
IOR test was performed ten times, and different write sizes were chosen to
demonstrate how smaller I/Os (and therefore more of them) result in more time
spent on lock contention.
