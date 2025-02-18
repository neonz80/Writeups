import struct

TYPE_PROGRAM = 0
TYPE_CODE = 3

def calc_checksum(values):
    output = 0
    for v in values:
        output ^= v
    return output

def create_code_header(name, size, address):
    assert(len(name) <= 10)
    data = b'\x00'
    data += struct.pack('B', TYPE_CODE)
    data += name.encode('ascii') + b'\x20' * (10-len(name))
    data += struct.pack('<H', size)
    data += struct.pack('<H', address)
    data += struct.pack('<H', 32768)
    data += struct.pack('B', calc_checksum(data))
    data = struct.pack('<H', len(data)) + data
    return data

def create_program_header(name, size, start_line, variable_area):
    assert(len(name) <= 10)
    data = b'\x00'
    data += struct.pack('B', TYPE_PROGRAM)
    data += name.encode('ascii') + b'\x20' * (10-len(name))
    data += struct.pack('<H', size)
    data += struct.pack('<H', start_line)
    data += struct.pack('<H', variable_area)
    data += struct.pack('B', calc_checksum(data))
    data = struct.pack('<H', len(data)) + data
    return data

def create_code_file(name, file_data, address, **kwargs):
    header = create_code_header(name, len(file_data), address)

    data = b'\xff'
    data += file_data
    data += struct.pack('B', calc_checksum(data))

    data = struct.pack('<H', len(data)) + data
    if kwargs.get('no_header', False):
        return data
    else:
        return header + data

def create_code_block(file_data):
    data = b'\xff'
    data += file_data
    data += struct.pack('B', calc_checksum(data))
    data = struct.pack('<H', len(data)) + data
    return data
    
def basic_line(line_no, basic):
    data = struct.pack('>H', line_no)
    data += struct.pack('<H', len(basic))
    data += basic
    return data

def basic_int(value):
    assert(value >= 0 and value <= 0xffff)
    num_str = "%d" % value
    data = num_str.encode('ascii')
    data += b'\x0e'
    data += b'\x00\x00'
    data += struct.pack('<H', value)
    data += b'\x00'
    return data
    
def create_simple_launcher(name, start_address, clear_address = None):

    if clear_address is None:
        clear_address = start_address
        
    ENTER = b'\x0d'
    CLEAR = b'\xfd'
    LOAD = b'\xef'
    CODE = b'\xaf'
    PRINT = b'\xf5'
    USR = b'\xc0'

    basic = basic_line(10, CLEAR + basic_int(clear_address-1) + ENTER)
    basic += basic_line(20, LOAD + b'""' + CODE + ENTER)
    basic += basic_line(30, PRINT + USR + basic_int(start_address) + ENTER)
    basic_len = len(basic)
    
    data = b'\xff' + basic
    data += struct.pack('B', calc_checksum(data))
    data = struct.pack('<H', len(data)) + data

    header = create_program_header(name, basic_len, 10, basic_len)

    return header + data
