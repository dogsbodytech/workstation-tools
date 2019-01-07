#!/usr/bin/env python3
import argparse
# Future Improvements:
# 	Support encoding input on the CLI

def html_character_reference(char):
    return '&#{};'.format(ord(char))

def encode_string(string):
    if '|' in string:
        print("WARNING: The SemanticMediaWiki can't deal with pipe ( | ) symbols in text fields.")
    encoded_chars = []
    for char in string:
        if char.isalnum():
            encoded_chars.append(char)
        else:
            encoded_chars.append(html_character_reference(char))

    return ''.join(encoded_chars)
        
def decode_string(string):
    import re
    decoded_chars = []
    position = 0
    while position < len(string):
        char = string[position]
        offset = 1
        if char.isalnum():
            decoded_chars.append(char)
        else:
            ref_num = re.match(r"""&#(\d*);.*""", string[position:]).group(1)
            offset = len(ref_num) + 3
            decoded_chars.append(chr(int(ref_num)))

        position += offset

    return ''.join(decoded_chars)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('string_to_encode', nargs='?')
    parser.add_argument('-d', '--string_to_decode')
    parser.allow_abbrev = False
    args = parser.parse_args()
    assert not (args.string_to_encode and args.string_to_decode)
    if args.string_to_encode:
        print(encode_string(args.string_to_encode))
    elif args.string_to_decode:
        print(decode_string(args.string_to_decode))
    else:
        print(encode_string(input("Please enter the string to encode:\n")))

if __name__ == '__main__':
    main()

