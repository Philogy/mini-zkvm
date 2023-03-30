mod ops;

global REG_COUNT: Field = 4;
global MAX_TRACE_LENGTH: Field = 100;
global MAX_PROGRAM_LENGTH: Field = 30;

// array of structs not supported yet :/
// struct TraceStep {
//   pc: Field,
//   op: u8
// }

fn check_trace_program(
  trace_length:    Field,
  trace_pcs:       [Field; MAX_TRACE_LENGTH],
  trace_ops:       [u8;    MAX_TRACE_LENGTH],
  trace_op_data:   [u64; MAX_TRACE_LENGTH],
  program_length:  Field,
  program_ops:     [u8;    MAX_PROGRAM_LENGTH],
  program_op_data: [u64; MAX_PROGRAM_LENGTH]
) {
  let plen: u16 = program_length as u16;
  let tlen: u16 = trace_length as u16;
  for pi in 0..MAX_PROGRAM_LENGTH {
    for ti in 0..MAX_TRACE_LENGTH {
      let trace_step_valid: bool =
        (trace_ops[ti]     == program_ops[pi]) &
        (trace_op_data[ti] == program_op_data[pi]) &
        (trace_pcs[ti] as u16 < plen);

      // Don't check trace if in padding, or not the PC.
      let dont_check_trace_step: bool =
        (trace_pcs[ti] != pi) |
        (ti as u16 >= tlen);

      constrain trace_step_valid | dont_check_trace_step;
    }
  }
}

fn check_execution(
  reg1_in:       u64,
  reg2_in:       u64,
  reg3_in:       u64,
  reg4_in:       u64,

  trace_length:  Field,
  // trace_pcs:    [Field; MAX_TRACE_LENGTH],
  trace_ops:     [u8;    MAX_TRACE_LENGTH],
  trace_op_data: [u64; MAX_TRACE_LENGTH],
  trace_reg1:    [u64; MAX_TRACE_LENGTH],
  trace_reg2:    [u64; MAX_TRACE_LENGTH],
  trace_reg3:    [u64; MAX_TRACE_LENGTH],
  trace_reg4:    [u64; MAX_TRACE_LENGTH]
) {
  let tlen: u16 = trace_length as u16;

  ops::check_step(
    trace_ops[0],
    trace_op_data[0],
    reg1_in, reg2_in, reg3_in, reg4_in,
    trace_reg1[0], trace_reg2[0], trace_reg3[0], trace_reg4[0]
  );

  for i in 1..(MAX_TRACE_LENGTH - 1) {
    if i as u16 < tlen {
      ops::check_step(
        trace_ops[i],
        trace_op_data[i],
        trace_reg1[i-1], trace_reg2[i-1], trace_reg3[i-1], trace_reg4[i-1],
        trace_reg1[i],   trace_reg2[i],   trace_reg3[i],   trace_reg4[i],
      );
    }
  }
}

fn check_register_end_states(
  trace_length: Field,
  trace_reg1:   [u64; MAX_TRACE_LENGTH],
  trace_reg2:   [u64; MAX_TRACE_LENGTH],
  trace_reg3:   [u64; MAX_TRACE_LENGTH],
  trace_reg4:   [u64; MAX_TRACE_LENGTH],
  reg1_out:     u64,
  reg2_out:     u64,
  reg3_out:     u64,
  reg4_out:     u64
) {
  for i in 0..MAX_TRACE_LENGTH {
    constrain (i != trace_length - 1) | (
      (trace_reg1[i] == reg1_out) &
      (trace_reg2[i] == reg2_out) &
      (trace_reg3[i] == reg3_out) &
      (trace_reg4[i] == reg4_out)
    );
  }
}

fn main(
  // Public input to the program
  reg1_in:         pub u64,
  reg2_in:         pub u64,
  reg3_in:         pub u64,
  reg4_in:         pub u64,

  // The execution trace.
  trace_length:        Field,
  trace_pcs:           [Field; MAX_TRACE_LENGTH],
  trace_ops:           [u8;    MAX_TRACE_LENGTH],
  trace_op_data:       [u64; MAX_TRACE_LENGTH],
  trace_reg1:          [u64; MAX_TRACE_LENGTH],
  trace_reg2:          [u64; MAX_TRACE_LENGTH],
  trace_reg3:          [u64; MAX_TRACE_LENGTH],
  trace_reg4:          [u64; MAX_TRACE_LENGTH],

  // The public program.
  program_length:  pub Field,
  program_ops:     pub [u8;    MAX_PROGRAM_LENGTH],
  program_op_data: pub [u64; MAX_PROGRAM_LENGTH],

  // The program's output
  reg1_out:        pub u64,
  reg2_out:        pub u64,
  reg3_out:        pub u64,
  reg4_out:        pub u64
) {
  constrain trace_length as u16 >= 1;

  check_trace_program(
    // Trace components
    trace_length, trace_pcs, trace_ops, trace_op_data,
    // Program components
    program_length, program_ops, program_op_data
  );

  check_execution(
    reg1_in,
    reg2_in,
    reg3_in,
    reg4_in,

    trace_length,
    // trace_pcs,
    trace_ops,
    trace_op_data,
    trace_reg1,
    trace_reg2,
    trace_reg3,
    trace_reg4
  );

  check_register_end_states(
    trace_length,
    trace_reg1, trace_reg2, trace_reg3, trace_reg4,
    reg1_out,   reg2_out,   reg3_out,   reg4_out
  );
}
