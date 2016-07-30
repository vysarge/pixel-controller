# pixel-controller

This repository contains code, primarily Verilog, for the purpose of producing and displaying matrix-based patterns.

Code is tested and confirmed working on the Nexys-4 DDR board, which uses the Artix-7 FPGA.  Using a different system requires modifying the nexys.v module to be compatible with your system's .xdc configuration file.  The project is being developed in Vivado 2016.2.

As of 30 Jul 2016, this code is capable of displaying a matrix of distinct color cells, output via VGA to a monitor.
