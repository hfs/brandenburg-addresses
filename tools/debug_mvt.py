#!/usr/bin/env python3

from vector_tile_pb2 import *

import argparse
import logging
import sys


def decode(parameterInteger):
    return ((parameterInteger >> 1) ^ (-(parameterInteger & 1)))

def is_clockwise(x, y):
    area2 = 0
    for i in range(len(x) - 1):
        area2 += x[i] * y[i+1]
        area2 -= x[i+1] * y[i]
    area2 += x[-1] * y[0]
    area2 -= x[0] * y[-1]
    return area2 >= 0

def print_tile(tile):
    for layer in tile.layers:
        logging.debug(f"Layer: {layer.name}")
        for feature in layer.features:
            logging.debug("Feature")
            cx, cy = 0, 0
            xs, ys = [], []
            logging.debug(f"({cx}, {cy})")
            geometry_iter = iter(feature.geometry)
            for geometry in geometry_iter:
                command = geometry & 0x7
                count = geometry >> 3
                if command == 1:
                    logging.debug(f"MoveTo[{count}]")
                    for i in range(count):
                        dx = decode(next(geometry_iter))
                        dy = decode(next(geometry_iter))
                        cx, cy = cx + dx, cy + dy
                        xs, ys = [cx], [cy]
                        logging.debug(f"({dx}, {dy}) -> ({cx}, {cy})")
                elif command == 2:
                    logging.debug(f"LineTo[{count}]")
                    for i in range(count):
                        dx = decode(next(geometry_iter))
                        dy = decode(next(geometry_iter))
                        cx, cy = cx + dx, cy + dy
                        xs.append(cx)
                        ys.append(cy)
                        logging.debug(f"({dx}, {dy}) -> ({cx}, {cy})")
                elif command == 7:
                    logging.debug("ClosePath")
                    if is_clockwise(xs, ys):
                        logging.info("is clockwise")
                    else:
                        logging.warn("is COUNTERclockwise")
                else:
                    raise ValueError(f"Unknown command integer {command}")


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Print infos about MVT tile files')
    parser.add_argument('files', type=str, nargs='+',
                        help="input file(s)")
    parser.add_argument('--verbose', action='store_true',
                        help="Print more infos about the file contents")
    parser.add_argument('--debug', action='store_true',
                        help="Print all information about the file contents")
    args = parser.parse_args(sys.argv[1:])

    if args.debug:
        logging.basicConfig(level=logging.DEBUG)
    elif args.verbose:
        logging.basicConfig(level=logging.INFO)
    else:
        logging.basicConfig(level=logging.WARN)

    for filename in args.files:
        with open(filename, 'rb') as infile:
            logging.info("File: %s", filename)
            tile_data = infile.read()
            tile = Tile.FromString(tile_data)
            print_tile(tile)

