# RISC-V Instruction Fetch (IF) Stage – Verilog

## Overview
This project implements a **synthesizable RISC-V Instruction Fetch (IF) stage** in Verilog HDL.  
The design focuses on correct PC update logic, instruction memory access, and pipeline register behavior.

## Features
- Program Counter (PC) update logic
- Instruction memory interface
- IF/ID pipeline register
- Synthesizable Verilog design
- Functional simulation using Vivado

---

## Tools & Technologies
- **Language:** Verilog HDL  
- **Simulation Tool:** Xilinx Vivado  
- **Design Type:** RTL (Register Transfer Level)

---

## Simulation
- Clock-driven simulation with reset control
- Verified PC progression and instruction fetch behavior
- Waveforms observed for:
  - `clk`
  - `reset`
  - `pc`
  - `pc_next`
  - `instr`
  - IF/ID pipeline signals

---

## Current Status
✔ Instruction Fetch stage successfully simulated  
✔ PC and instruction signals verified  
🚧 Decode and Execute stages planned for future extension

---

## How to Run
1. Open Xilinx Vivado
2. Create a new RTL project
3. Add all `.v` files as **Design Sources**
4. Add `riscv_tb.v` as **Simulation Source**
5. Set `riscv_tb` as top module for simulation
6. Run Behavioral Simulation

---

## Future Work
- Instruction Decode (ID) stage
- Execute (EX) stage integration
- Data memory and Write Back stages
- Full 5-stage pipelined RISC-V processor
- Forwarding and hazard resolution logic

---

## Author
Palak

