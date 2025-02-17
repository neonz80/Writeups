import zxtap
import argparse
import re

def read_symbols(filename):
    output = {}
    with open(filename, 'r') as f:
        r = re.compile('(?P<name>[\w._!?#@]+): EQU 0x(?P<address>[0-9A-Fa-f]+)')
        #r = re.compile('(?P<name>[\w._!?#@]+): EQU 0x.*')
        for line in f.readlines():
            m = r.match(line)
            output[m.group('name')] = int(m.group('address'), 16)
    return output

def parse_int(s):
    return int(s, 0)

if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    parser.add_argument('input')
    parser.add_argument('-o', '--output', type=str, required=True)
    parser.add_argument('-a', '--address', type=parse_int, required = False)
    parser.add_argument('-e', '--entrypoint', type=parse_int, required = False)
    parser.add_argument('-s', '--symbols', type=str, required=False)
    parser.add_argument('-l', '--launcher-name', type=str, default="LAUNCHER")
    parser.add_argument('-c', '--code-name', type=str, default="CODE")
    
    args = parser.parse_args()

    if args.symbols is not None:

        if (args.address is not None or args.entrypoint is not None):
            raise Exception("Address and entrypoint can not be specified when using symbols")

    if args.symbols is not None:
        symbols = read_symbols(args.symbols)
        if 'start' not in symbols:
            raise Exception("Start symbol not found")
        address = symbols['start']
        if 'entrypoint' in symbols:
            entrypoint = symbols['entrypoint']
        else:
            entrypoint = address
    else:
        if args.address is None:
            raise Exception("Specifiy address or symbols")
        address = args.address
        if args.entrypoint is not None:
            entrypoint = args.entrypoint
        else:
            entrypoint = address
        
    with open(args.input, 'rb') as f:
        data = f.read()

    tap = zxtap.create_simple_launcher(args.launcher_name, entrypoint, 0x6000)
    tap += zxtap.create_code_file(args.code_name, data, address)
    
    with open(args.output, 'wb') as f:
        f.write(tap)
