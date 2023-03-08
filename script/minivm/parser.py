from enum import Enum
from collections import namedtuple
from typing import Sequence, Any
from parsimonious.grammar import Grammar
from parsimonious.nodes import Node, NodeVisitor


_RAW_GRAMMAR = r'''
program = line? ("\n" line)*
line = spacing? obj? spacing?

obj = alias / operation / jump / jump_label

alias = word spacing "as" spacing register

operation = arithmetic_op / arrange_op / set_op
arithmetic_op = ("ADD" / "SUB" / "MUL" / "DIV") spacing value spacing value
arrange_op = ("COPY" / "SWAP") spacing var spacing var
set_op = "SET" spacing var spacing number

jump = direct_jump / conditional_jump
direct_jump = "jump" spacing word
conditional_jump = "jumpif" spacing condition spacing word
condition = var spacing? ("==" / "!=" / ">=" / "<=" / ">" / "<") spacing? var
jump_label = word ":"

value = var / number
var =  register / word
word = !(register space) ~"[A-Z][A-Z0-9_-]*"i
number = hex_number / base10_number
base10_number = ~"[0-9]+"
hex_number = "0x" ~"[0-9A-Z]"i
register = "r1" / "r2" / "r3" / "r4"
spacing = space+
space = " " / "\t"
'''

MINIVM_GRAMMAR = Grammar(_RAW_GRAMMAR)


class Registers(Enum):
    R1 = 0
    R2 = 1
    R3 = 2
    R4 = 3


Alias = namedtuple('Alias', ['name', 'reg'])
NamedRegister = namedtuple('NamedRegister', ['name'])
DirectValue = namedtuple('DirectValue', ['value'])
JumpLabel = namedtuple('JumpLabel', ['name'])
Operation = namedtuple('Operation', ['op', 'regs', 'extra'])


def reg_from_node(reg_node: Node):
    if reg_node.expr_name in ('value', 'var'):
        return reg_from_node(reg_node.children[0])

    if reg_node.expr_name == 'number':
        return value_from_node(reg_node)

    if reg_node.expr_name == 'register':
        return Registers(int(reg_node.text[-1:]) - 1)
    if reg_node.expr_name == 'word':
        return NamedRegister(reg_node.text)

    raise ValueError(f'Unrecognized node type "{reg_node.expr_name}"')


def value_from_node(value_node: Node):
    inner_node = value_node.children[0]

    if inner_node.expr_name == 'base10_number':
        return DirectValue(int(value_node.text))
    if inner_node.expr_name == 'hex_number':
        _, digits = value_node
        return DirectValue(int(digits.text, 16))

    raise ValueError(f'Unrecognized value node {inner_node}')


class _MiniVMAssemblyVisitor(NodeVisitor):
    def visit_program(self, _, visited_children):
        line1, lines = visited_children
        return lines
        # return [cn[0] for cn in visited_children]

    def visit_line(self, _, visited_children):
        _, obj, *_ = visited_children
        return obj

    def visit_obj(self, _, visited_children):
        return next(iter(visited_children))

    def visit_comment(self, *_):
        return None

    def visit_operation(self, _, visited_children):
        return next(iter(visited_children))

    def visit_arithmetic_op(self, node, _):
        op, _, r1, _, r2 = node
        return Operation(op.text, [reg_from_node(r1), reg_from_node(r2)], None)

    def visit_arrange_op(self, node, _):
        op, _, r1, _, r2 = node
        return Operation(
            op.text,
            [reg_from_node(r1), reg_from_node(r2)],
            None
        )

    def visit_set_op(self, node, _):
        _, _, r1, _, value = node
        return Operation('SET', [reg_from_node(r1)], value_from_node(value))

    def visit_jump(self, _, visited_children):
        return next(iter(visited_children))

    def visit_direct_jump(self, node, _):
        _, _, label_node = node
        return Operation('JUMP', [], JumpLabel(label_node.text))

    def visit_conditional_jump(self, node, _):
        _, _, condition_node, _, label = node
        r1, _, comp_node, _, r2 = condition_node
        comp = comp_node.text
        if comp == '==':
            op = 'JEQ'
        elif comp == '!=':
            op = 'JNEQ'
        elif comp == '>=':
            op = 'JGTE'
        elif comp == '>':
            op = 'JGT'
        elif comp == '<=':
            op = 'JGTE'
            r1, r2 = r2, r1
        elif comp == '<':
            op = 'JGT'
            r1, r2 = r2, r1
        else:
            raise ValueError(f'Invalid comp "{comp}')
        return Operation(op, [reg_from_node(r1), reg_from_node(r2)], JumpLabel(label.text))

    def visit_jump_label(self, node, _):
        label_node, _ = node
        return JumpLabel(label_node.text)

    def visit_alias(self, node, _):
        word, _, _, _, reg = node
        return Alias(word.text, reg_from_node(reg))

    def generic_visit(self, node: Node, visited_children: Sequence[Any]):
        flattened_children = []
        for child in visited_children:
            if isinstance(child, list):
                flattened_children += child
            else:
                flattened_children.append(child)

        return [
            child
            for child in flattened_children
            if not isinstance(child, Node) or child.text.strip()
        ] or node


class ParseError(Exception):
    pass


def validate_parsed_code(tokens):
    aliased_regs = dict()
    found_labels = set()
    for token in tokens:
        if isinstance(token, Alias):
            if token.reg in aliased_regs:
                raise ParseError(
                    f'Cannot define 2 aliases "{aliased_regs[token.reg]}" and "{token.name}"'
                )
            aliased_regs[token.reg] = token.name
        if isinstance(token, JumpLabel):
            if token.name in found_labels:
                raise ParseError(
                    f'Defined label "{token.name}" more than once'
                )
            found_labels.add(token.name)


def parse(program: str):
    ast = MINIVM_GRAMMAR.parse(program)
    parsed_tokens = _MiniVMAssemblyVisitor().visit(ast)
    validate_parsed_code(parsed_tokens)
    return parsed_tokens


if __name__ == '__main__':
    program = '''
hey as r1
hey2 as r2

DIV r1 2

jumpif r2 >= r2 loca

MUL r1 r2

loca:
'''
    print(f'parse(program): {parse(program)}')
