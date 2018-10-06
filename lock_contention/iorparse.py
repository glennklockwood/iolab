#!/usr/bin/env python
"""
Very simple parser to extract performance measurements from the stdout of an IOR
job.
"""

import json
import argparse

def parse(ior_log, access=None):
    """Extract performance results from the stdout stream of an IOR run

    Args:
        ior_log (iterable): Any object that can be iterated to produce lines of
            output generated by IOR
        access (str or None): Return only "read," "write," "remove," or "all"
            access modes.  If None, return results from all access modes.
    """
    if access and access == "all":
        # access == None is equivalent to returning all access types
        access = None
    parsing = False
    results = []
    for line in ior_log:
        if not parsing:
            # begin parsing results lines when the "access" line is found
            if line.startswith('access'):
                parsing = True
        else:
            if line.startswith('Max'):
                # turn off parsing results when the terminal summary line is found
                parsing = False
            elif line.startswith('write') or line.startswith('read') or line.startswith('remove'):
                # parse read, write, and remove lines.  readcheck/writecheck/etc
                # aren't yet supported.
                fields = line.split()
                if not access or fields[0] == access:
                    results.append({
                        'access': fields[0],
                        'bw_mibs': float(fields[1]) if fields[1] != "-" else -1.0,
                        'blocksize_kib': float(fields[2]) if fields[2] != "-" else -1.0,
                        'xfersize_kib': float(fields[3]) if fields[3] != "-" else -1.0,
                        'open_secs': float(fields[4]) if fields[4] != "-" else -1.0,
                        'io_secs': float(fields[5]) if fields[5] != "-" else -1.0,
                        'close_secs': float(fields[6]) if fields[6] != "-" else -1.0,
                        'total_secs': float(fields[7]) if fields[7] != "-" else -1.0,
                        'iteration': int(fields[8]) if fields[8] != "-" else -1,
                    })

    return results

def main(argv=None):
    """Command-line wrapper around parse()

    Args:
        argv (list or None): Command-line arguments to pass to argparse.  If
            None, fall back to the default of using sys.argv
    """
    parser = argparse.ArgumentParser(add_help=False)
    parser.add_argument("iorlog", type=str, help="path to IOR log")
    parser.add_argument("--access", type=str, help="only return read, write, or remove timings (default: all)")
    args = parser.parse_args(argv)
    results = parse(open(args.iorlog, 'r'), access=args.access)
    print(json.dumps(results, indent=4, sort_keys=True))

if __name__ == "__main__":
    main()