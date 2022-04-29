#!/usr/bin/env python

import json
import argparse

import n10ioana.parse
import pandas

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("file", nargs="+", type=str, help="ior output file")
    parser.add_argument("-j", "--json", action="store_true", help="print output as json")
    args = parser.parse_args()

    for file in args.file:
        parsed = n10ioana.parse.IorOutput(open(file, "r"))
        print(file)
        if args.json:
            print(json.dumps(parsed, sort_keys=True, indent=4))
        else:
            print(pandas.DataFrame.from_records(parsed["results"]))
