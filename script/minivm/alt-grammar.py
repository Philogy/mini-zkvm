_RAW_GRAMMAR = r'''
program = (spacing obj? spacing "\n" spacing)*

obj = alias / logic_obj
logic_obj = control / mutation

control = if_block / while_block / do_while_block

alias = word spacing "as" spacing register spacing ";"

mutation = swap / assignment
assigment = var spacing "=" spacing value (spacing op spacing value)? spacing ";"
swap = var spacing "," spacing var spacing "=" spacing var spacing "," spacing var spacing ";"

value = number / var
var = register / word
spacing = space*

word = !(register space) ~"[A-Z][A-Z0-9_-]*"i
number = ~"(0x[0-9A-Z]+|[0-9]+)"
register = "r1" / "r2" / "r3" / "r4"
space = " " / "\t"
'''
