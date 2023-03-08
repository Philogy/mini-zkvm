
from .parser import Alias, NamedRegister, DirectValue, JumpLabel, Operation


def get_aliases(tokens):
    return {
        token.name: token.reg
        for token in tokens
        if isinstance(token, Alias)
    }


def get_jump_destinations(tokens):
    jump_dests = dict()
    i = 0
    for token in tokens:
        if isinstance(token, JumpLabel):
            jump_dests[token.name] = i
        else:
            i += 1
    return jump_dests


def tokens_to_program(tokens):
    bytecode = b''
    comp_values = []

    aliases = get_aliases(tokens)
    jump_dests = get_jump_destinations(tokens)

    for token in tokens:
        if not isinstance(token, Operation):
            continue

        if token.op == ''
    return bytecode, comp_values
