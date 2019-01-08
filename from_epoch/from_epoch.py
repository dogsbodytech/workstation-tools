#!/usr/bin/env python3
import time
import argparse

# I want to be able to pass this script milli/micro/nano seconds and have it give the correct output.  I'm going to do this by deciding all times will never be further into the future than twice what the current day is.

def to_gregorian(since_epoch):
    since_epoch = int(since_epoch)
    current_time = time.time()
    while 2 * current_time < since_epoch:
        since_epoch /= 1000

    return time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(since_epoch))

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('since_epoch', type=float, help='The number to convert from epoch to a standard calendar')
    args = parser.parse_args()
    print(to_gregorian(args.since_epoch))

if __name__ == '__main__':
    main()

