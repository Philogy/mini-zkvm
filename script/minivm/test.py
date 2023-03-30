from parser import parse

if __name__ == '__main__':
    program = '''
hey as r1
hey2 as r2

DIV r1 2

jumpif r2 >= hey2 loca

MUL r1 r2

jump loca
COPY r1 hey

loca:
'''
    parsed_code = parse(program)
    print('tree:', parsed_code)
