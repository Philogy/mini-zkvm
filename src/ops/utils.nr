fn get_regs(
  op: u8,
  reg1: Field,
  reg2: Field,
  reg3: Field,
  reg4: Field
) -> (Field, Field) {
  let mut regA: Field = 0;
  let mut regB: Field = 0;

  if (op & 0x02) == 0 {
    if (op & 0x01) == 0 {
      regA = reg1;
    } else {
      regA = reg2;
    }
  } else {
    if (op & 0x01) == 0 {
      regA = reg3;
    } else {
      regA = reg4;
    }
  }
  // Add from register 2
  if (op & 0x08) == 0 {
    if (op & 0x04) == 0 {
      regB = reg1;
    } else {
      regB = reg2;
    }
  } else {
    if (op & 0x04) == 0 {
      regB = reg3;
    } else {
      regB = reg4;
    }
  }

  let retTup: (Field, Field) = (regA, regB);

  retTup
}
