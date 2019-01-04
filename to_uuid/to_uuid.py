#!/usr/bin/env python3
import uuid
import sys
import argparse

def to_uuid(string):
    """
    Mirroring the jinja filter implemented in ansible

    Input a string. Returns the uuid ansible would generate as a string.
    """
    if sys.version_info[0] == 2:
        string = string.encode('utf-8')
    
    # This the seed Ansible has chosen for their UUID's
    return str(uuid.uuid5(uuid.UUID('361E6D51-FAEC-444A-9079-341386DA8E2E'), string))

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('string', help='The string to generate our uuid from')
    args = parser.parse_args()
    print(to_uuid(args.string))

if __name__ == '__main__':
    main()

