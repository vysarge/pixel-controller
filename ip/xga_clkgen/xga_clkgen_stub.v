// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.3 (win64) Build 1368829 Mon Sep 28 20:06:43 MDT 2015
// Date        : Fri May 27 14:56:53 2016
// Host        : Dell running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               C:/Users/User/Documents/repos/pixel-controller/ip/xga_clkgen/xga_clkgen_stub.v
// Design      : xga_clkgen
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module xga_clkgen(clk_100mhz, clk_65mhz, reset, locked)
/* synthesis syn_black_box black_box_pad_pin="clk_100mhz,clk_65mhz,reset,locked" */;
  input clk_100mhz;
  output clk_65mhz;
  input reset;
  output locked;
endmodule
