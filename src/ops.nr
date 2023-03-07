mod utils;

fn check_step(
  op: u8,
  op_data: Field,
  reg1:      Field, reg2:      Field, reg3:      Field, reg4:      Field,
  reg1_next: Field, reg2_next: Field, reg3_next: Field, reg4_next: Field
) {
  if (op & 0x80) == 0 {
    // Arithmetic Operations
    if (op & 0x20) == 0 {
      if (op & 0x10) == 0 {
        check_op_add(
          op,
          reg1,      reg2,      reg3,      reg4,
          reg1_next, reg2_next, reg3_next, reg4_next
        );
      } else {
        check_op_sub(
          op,
          reg1,      reg2,      reg3,      reg4,
          reg1_next, reg2_next, reg3_next, reg4_next
        );
      }
    } else {
      if (op & 0x10) == 0 {
        check_op_mul(
          op,
          reg1,      reg2,      reg3,      reg4,
          reg1_next, reg2_next, reg3_next, reg4_next
        );
      } else {
        check_op_div(
          op,
          reg1,      reg2,      reg3,      reg4,
          reg1_next, reg2_next, reg3_next, reg4_next
        );
      }
    }
  } else {
    if (op & 0x10) == 0 {
      check_op_swap(
        op,
        reg1,      reg2,      reg3,      reg4,
        reg1_next, reg2_next, reg3_next, reg4_next
      );
    } else {
      // ops::check_op_copy(
      //   op,
      //   reg1,   reg2,   reg3,   reg4,
      //   reg1_next, reg2_next, reg3_next, reg4_next
      // );
    }
  }

}

fn check_op_add(
  op: u8,
  reg1:      Field, reg2:      Field, reg3:      Field, reg4:      Field,
  reg1_next: Field, reg2_next: Field, reg3_next: Field, reg4_next: Field
) {
  let (regA, regB): (Field, Field) = utils::get_regs(op, reg1, reg2, reg3, reg4);
  constrain reg1_next == regA + regB;
  constrain reg2_next == reg2;
  constrain reg3_next == reg3;
  constrain reg4_next == reg4;
}

fn check_op_sub(
  op: u8,
  reg1:      Field, reg2:      Field, reg3:      Field, reg4:      Field,
  reg1_next: Field, reg2_next: Field, reg3_next: Field, reg4_next: Field
) {
  let (regA, regB): (Field, Field) = utils::get_regs(op, reg1, reg2, reg3, reg4);
  constrain reg1_next == regA - regB;
  constrain reg2_next == reg2;
  constrain reg3_next == reg3;
  constrain reg4_next == reg4;
}

fn check_op_mul(
  op: u8,
  reg1:      Field, reg2:      Field, reg3:      Field, reg4:      Field,
  reg1_next: Field, reg2_next: Field, reg3_next: Field, reg4_next: Field
) {
  let (regA, regB): (Field, Field) = utils::get_regs(op, reg1, reg2, reg3, reg4);
  constrain reg1_next == regA * regB;
  constrain reg2_next == reg2;
  constrain reg3_next == reg3;
  constrain reg4_next == reg4;
}

fn check_op_div(
  op: u8,
  reg1:      Field, reg2:      Field, reg3:      Field, reg4:      Field,
  reg1_next: Field, reg2_next: Field, reg3_next: Field, reg4_next: Field
) {
  let (regA, regB): (Field, Field) = utils::get_regs(op, reg1, reg2, reg3, reg4);
  constrain reg1_next == regA / regB;
  constrain reg2_next == reg2;
  constrain reg3_next == reg3;
  constrain reg4_next == reg4;
}

fn check_op_swap(
  op: u8,
  reg1:      Field, reg2:      Field, reg3:      Field, reg4:      Field,
  reg1_next: Field, reg2_next: Field, reg3_next: Field, reg4_next: Field
) {
  if (op & 0x08) == 0 {
    if (op & 0x04) == 0 {
      // REG1 <=> ?
      if (op & 0x02) == 0 {
        constrain reg3_next == reg3;
        constrain reg4_next == reg4;
        if (op & 0x01) == 0 {
          constrain reg1_next == reg1;
          constrain reg2_next == reg2;
        } else {
          constrain reg1_next == reg2;
          constrain reg2_next == reg1;
        }
      } else {
        constrain reg2_next == reg2;
        if (op & 0x01) == 0 {
          constrain reg1_next == reg3;
          constrain reg3_next == reg1;
          constrain reg4_next == reg4;
        } else {
          constrain reg1_next == reg4;
          constrain reg3_next == reg3;
          constrain reg4_next == reg1;
        }
      }
    } else {
      // REG2 <=> ?
      if (op & 0x02) == 0 {
        constrain reg3_next == reg3;
        constrain reg4_next == reg4;
        if (op & 0x01) == 0 {
          constrain reg1_next == reg2;
          constrain reg2_next == reg1;
        } else {
          constrain reg1_next == reg1;
          constrain reg2_next == reg2;
        }
      } else {
        constrain reg1_next == reg1;
        if (op & 0x01) == 0 {
          constrain reg2_next == reg3;
          constrain reg3_next == reg2;
          constrain reg4_next == reg4;
        } else {
          constrain reg2_next == reg4;
          constrain reg3_next == reg3;
          constrain reg4_next == reg2;
        }
      }
    }
  } else {
    if (op & 0x04) == 0 {
      // REG3 <=> ?
      if (op & 0x02) == 0 {
        constrain reg4_next == reg4;
        if (op & 0x01) == 0 {
          constrain reg1_next == reg3;
          constrain reg2_next == reg2;
          constrain reg3_next == reg1;
        } else {
          constrain reg1_next == reg1;
          constrain reg2_next == reg3;
          constrain reg3_next == reg2;
        }
      } else {
        constrain reg1_next == reg1;
        constrain reg2_next == reg2;
        if (op & 0x01) == 0 {
          constrain reg3_next == reg3;
          constrain reg4_next == reg4;
        } else {
          constrain reg3_next == reg4;
          constrain reg4_next == reg3;
        }
      }
    } else {
      // REG4 <=> ?
      if (op & 0x02) == 0 {
        constrain reg3_next == reg3;
        if (op & 0x01) == 0 {
          constrain reg1_next == reg4;
          constrain reg2_next == reg2;
          constrain reg4_next == reg1;
        } else {
          constrain reg1_next == reg1;
          constrain reg2_next == reg4;
          constrain reg4_next == reg2;
        }
      } else {
        constrain reg1_next == reg1;
        constrain reg2_next == reg2;
        if (op & 0x01) == 0 {
          constrain reg3_next == reg4;
          constrain reg4_next == reg3;
        } else {
          constrain reg3_next == reg3;
          constrain reg4_next == reg4;
        }
      }
    }
  }
}

// fn check_op_copy(
//   op: u8,
//   reg1:      Field, reg2:      Field, reg3:      Field, reg4:      Field,
//   reg1_next: Field, reg2_next: Field, reg3_next: Field, reg4_next: Field
// ) {
//   let (regA, regB): (Field, Field) = get_regs(op, reg1, reg2, reg3, reg4);
//   constrain reg1_next == regA / regB;
//   constrain reg2_next == reg2;
//   constrain reg3_next == reg3;
//   constrain reg4_next == reg4;
// }
