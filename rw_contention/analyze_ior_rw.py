#!/usr/bin/env python
"""
Summarize the output of a single experiment run.  Specify the stdout files from
every IOR task launched within the job and get a summary of performance.

    ./analyze_ior_rw.py results/*_867662.out
"""

import os
import sys
import json

counter_labels = {
    'overlap_readrate': 'Overlapping I/O read rate (MiB/s)',
    'overlap_writerate': 'Overlapping I/O write rate (MiB/s)',
    'full_readrate': 'Uncontended read rate (MiB/s)',
    'full_writerate': 'Uncontended write rate (MiB/s)',
    'overlap_rwrate': 'Overlapping I/O total rate (MiB/s)',
    'overlap_rwrate_pct_peak': 'Fraction peak performance achieved while overlapping (%)',
}

if len(sys.argv) < 2:
    sys.stderr.write("Syntax: %s <ior_stdout3> [ior_stdout2 [...]]\n" % sys.argv[0])
    sys.exit(1)

results = {}
for filename in sys.argv[1:]:
    rate = None
    direction = None
    for line in open(filename, 'r').readlines():
        if (line.startswith('read') or line.startswith('write')) and 'POSIX' in line:
            tokens = line.split()
            rate = float(tokens[1])
            direction = tokens[0]
        if rate is not None:
            if 'read_overlap' in filename:
                key = 'overlap_readrate'
            elif 'write_overlap' in filename:
                key = 'overlap_writerate'
            elif 'rw_full' in filename:
                key = 'full_%srate' % direction
            else:
                continue # invalid file
            results[key] = rate

results['overlap_rwrate'] = results['overlap_readrate'] + results['overlap_writerate']
results['overlap_rwrate_pct_peak'] = (100.0 * results['overlap_rwrate'] / max(results['full_readrate'], results['full_writerate']))

for key in sorted(results.keys()):
    print "%s: %.2f" % (counter_labels.get(key, key), results[key])
