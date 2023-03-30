fn get_regs(
  op: u8,
  reg1: u64,
  reg2: u64,
  reg3: u64,
  reg4: u64
) -> (u64, u64) {
  let mut regA: u64 = 0;
  let mut regB: u64 = 0;

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

  let retTup: (u64, u64) = (regA, regB);

  retTup
}
