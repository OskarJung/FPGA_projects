# FPGA & Digital Design Portfolio

![Verilog](https://img.shields.io/badge/Language-Verilog-blue.svg)
![Vivado](https://img.shields.io/badge/Tool-Xilinx_Vivado-orange.svg)
![Academic](https://img.shields.io/badge/Status-Academic_Projects-red.svg)

This repository contains a collection of hardware modules and systems designed in **Verilog** and synthesized using **Xilinx Vivado**.

## Project Catalog

The table below lists the implemented projects with links to their detailed documentation and source files.

| Project | Description | Technologies | Documentation |
| :--- | :--- | :--- | :---: |
| **Complex Logic Module** | Parameterized AND/OR gate tree utilizing `generate` loops. | Verilog, RTL, Simulation | [Link](./complex_logic_module) |
| **UART Transceiver** | RS-232 serial communication module with a Finite State Machine (FSM). | Verilog, FSM, UART | [Link](./UART_Transceiver) |
| **RGB to HSV** | Hardware accelerator for color space conversion in a video processing pipeline. | DSP, Video Processing | [WIP] |

## Development Environment

* **Software:** Xilinx Vivado 2022.2.
* **Hardware:** Xilinx 7-series and MPSoC boards (e.g., Zybo, Kria KV260)
* **Simulation:** Vivado Simulator (XSim)

## Repository Structure

Each project subfolder follows a unified directory structure to streamline code analysis and automated builds:

* `src/`: Synthesizable Verilog source files (`.v`).
* `sim/`: Testbenches for behavioral simulation.
* `docs/`: RTL schematics and simulation waveforms.
* `build_project.tcl`: Tcl script for automated Vivado project reconstruction.

## How to Build

To recreate any project locally:
1. Clone the repository: `git clone https://github.com/YourUser/FPGA_project.git`
2. Navigate to the desired project directory (e.g., `cd complex_logic_module`).
3. Open Vivado and run the following command in the Tcl Console: `source build_project.tcl`.
