// (c) Copyright 2011 - 2013 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//------------------------------------------------------------------------------
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version: $Revision: #1 $
//  \   \         
//  /   /         Filename: $File: //Groups/video_ip/demos/A7/xapp1097_a7_sdi_demos/Verilog/ac701_sdi_demo/ac701_sdi_demo.v $
// /___/   /\     Timestamp: $DateTime: 2013/09/30 13:31:35 $
// \   \  /  \
//  \___\/\___\
//
// Description:
//  This module is the top level HDL file for the Dual SDI demo for the AC701
//  evaluation board.
//
// This version adds some delay before asserting the rx_refclk_stable and
// tx_refclk_stable signals so that the GTP starts reliably after FPGA 
// configuration.
//
//------------------------------------------------------------------------------
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//------------------------------------------------------------------------------

`timescale 1ns / 1ps

module ac701_sdi_demo (
    input  wire clk_27M,
       
    input  wire mgtp_refclk0_p,
    input  wire mgtp_refclk0_n,  
    input  wire mgtp_rx0_p,
    input  wire mgtp_rx0_n,
    output wire mgtp_tx0_p,
    output wire mgtp_tx0_n,
    
//    input  wire mgtp_rx1_p,
//    input  wire mgtp_rx1_n,
//    output wire mgtp_tx1_p,
//    output wire mgtp_tx1_n,
    
    output wire sdi0_sd_hd,
//    output wire sdi1_sd_hd,
    output wire fpga_led,
    output wire fpga_led2
);


parameter USE_CHIPSCOPE = "FALSE";

// Global signals
//wire        clk_27M_in;
//wire        clk_27M;
wire        mgtclk_148_5;
wire        mgtclk_148_35;
wire        pll0lock;
wire        pll0reset;
wire        pll0clk;
wire        pll0refclk;
wire        pll1lock;
wire        pll1reset;
wire        pll1clk;
wire        pll1refclk;



wire        tx0_outclk;
wire        tx0_usrclk;
wire        tx0_slew;
assign sdi0_sd_hd = tx0_slew;

wire        tx1_outclk;
wire        tx1_usrclk;
wire        tx1_slew;
//assign sdi1_sd_hd = tx1_slew;
wire        rx0_outclk;
wire        rx0_usrclk;
wire        rx0_locked;
assign fpga_led = rx0_locked;

wire [3:0]  rx0_t_family;
wire [3:0]  rx0_t_rate;
wire        rx0_t_scan;
wire        rx0_level_b;
wire        rx0_m;
wire [1:0]  rx0_mode;

wire        rx1_outclk;
wire        rx1_usrclk;
wire        rx1_locked;
assign fpga_led2 = rx1_locked;

wire [3:0]  rx1_t_family;
wire [3:0]  rx1_t_rate;
wire        rx1_t_scan;
wire        rx1_level_b;
wire        rx1_m;
wire [1:0]  rx1_mode;

wire [3:0]  lcd_d;

reg  [24:0] refclk_stable_dly = 1;
wire        refclk_stable_tc;
reg         refclk_stable = 1'b0;


// ChipScope signals
wire [35:0] control0;
wire [35:0] control1;
wire [35:0] control2;
wire [35:0] control3;
wire [35:0] control4;
wire [35:0] control5;
wire [35:0] control6;



BUFG BUFGTX0 (
    .I      (tx0_outclk),
    .O      (tx0_usrclk));

BUFG BUFGRX0 (
    .I      (rx0_outclk),
    .O      (rx0_usrclk));

//BUFG BUFGTX1 (
//    .I      (tx1_outclk),
//    .O      (tx1_usrclk));

//BUFG BUFGRX1 (
//    .I      (rx1_outclk),
//    .O      (rx1_usrclk));


//
// This is the 148.5 MHz MGT reference clock input from FMC SDI mezzanine board.
//
//(* LOC = "IBUFDS_GTE2_X0Y0" *)
IBUFDS_GTE2 MGTCLKIN0 (
    .I          (mgtp_refclk0_p),
    .IB         (mgtp_refclk0_n),
    .CEB        (1'b0),
    .O          (mgtclk_148_5),
    .ODIV2      ());

//assign USER_SMA_GPIO_P = tx0_usrclk;

//
// 148.35 MHz MGT reference clock input from the FMC SDI mezzanine board.
//
//(* LOC = "IBUFDS_GTE2_X0Y1" *)
//IBUFDS_GTE2 MGTCLKIN1 (
//    .I          (SFP_MGT_CLK1_C_P),
//    .IB         (SFP_MGT_CLK1_C_N),
//    .CEB        (1'b0),
//    .O          (mgtclk_148_35),
//    .ODIV2      ());

//
// Generate approximately 1.25 second delay after FPGA configuration before
// releasing the refclk_stable signal in order to make sure reference clocks
// are stable.
//
always @ (posedge clk_27M)
    if (!refclk_stable)
        refclk_stable_dly <= refclk_stable_dly + 1;

assign refclk_stable_tc = &refclk_stable_dly;

always @ (posedge clk_27M)
    if (refclk_stable_tc)
        refclk_stable <= 1'b1;

//------------------------------------------------------------------------------
// SDI RX/TX modules
//
// Each of these modules contains the SDI wrapper (containing the SDI core and
// the SDI control logic), the GTP transceiver, video pattern generators to 
// drive the SDI transmitter, and ChipScope or Vivado Analyzer modules to 
// control and monitor the SDI interface.
//
wire [9:0]y;
wire [9:0]cbcr;
a7_sdi_rxtx #(
    .USE_CHIPSCOPE      (USE_CHIPSCOPE))
SDI0 (
    .clk                (clk_27M),
    .tx_outclk          (tx0_outclk),//----+ BUFG
    .tx_usrclk          (tx0_usrclk),//<---+
    .tx_refclk_stable   (refclk_stable),
    .tx_plllock         (pll0lock & pll1lock),  // GTP TX uses both PLL0 and PLL1
    .tx_pllreset        (pll1reset),            // but only resets PLL1 because PLL0 is reset by RX
    .tx_slew            (tx0_slew),
    .tx_txen            (),
    .rx_refclk_stable   (refclk_stable),
    .rx_plllock         (pll0lock),             // RX only uses PLL0
    .rx_pllreset        (pll0reset),
    .rx_outclk          (rx0_outclk),//----+ BUFG
    .rx_usrclk          (rx0_usrclk),//<---+
    .rx_locked          (rx0_locked),
    .rx_t_family        (rx0_t_family),
    .rx_t_rate          (rx0_t_rate),
    .rx_t_scan          (rx0_t_scan),
    .rx_level_b         (rx0_level_b),
    .rx_m               (rx0_m),
    .rx_mode            (rx0_mode),
    .drpclk             (clk_27M),
    .txp                (mgtp_tx0_p),
    .txn                (mgtp_tx0_n),
    .rxp                (mgtp_rx0_p),
    .rxn                (mgtp_rx0_n),
    .pll0clk            (pll0clk),
    .pll0refclk         (pll0refclk),
    .pll1clk            (pll1clk),
    .pll1refclk         (pll1refclk),
    .control0           (control1),
    .control1           (control2),
    .control2           (control3),
    .rx_ds1a            (y),
    .rx_ds2a            (cbcr)
);

axisv1080_ycrcb2rgb axisv1080_ycrcb2rgb_0
(
    .aclk(),
    .aclken(1'b1),
    .aresetn(1'b0),
    .s_axis_video_tdata(), 
    .s_axis_video_tready(), 
    .s_axis_video_tvalid(), 
    .s_axis_video_tlast(), 
    .s_axis_video_tuser_sof(), 
    
    .m_axis_video_tdata(), 
    .m_axis_video_tvalid(), 
    .m_axis_video_tready(), 
    .m_axis_video_tlast(), 
    .m_axis_video_tuser_sof()
);
//a7_sdi_rxtx #(
//    .USE_CHIPSCOPE      (USE_CHIPSCOPE))
//SDI1 (
//    .clk                (clk_27M),
//    .tx_outclk          (tx1_outclk),
//    .tx_usrclk          (tx1_usrclk),
//    .tx_refclk_stable   (refclk_stable),
//    .tx_plllock         (pll0lock & pll1lock),
//    .tx_pllreset        (),
//    .tx_slew            (tx1_slew),
//    .tx_txen            (),
//    .rx_refclk_stable   (refclk_stable),
//    .rx_plllock         (pll0lock),             // RX only uses PLL0
//    .rx_pllreset        (),
//    .rx_outclk          (rx1_outclk),
//    .rx_usrclk          (rx1_usrclk),
//    .rx_locked          (rx1_locked),
//    .rx_t_family        (rx1_t_family),
//    .rx_t_rate          (rx1_t_rate),
//    .rx_t_scan          (rx1_t_scan),
//    .rx_level_b         (rx1_level_b),
//    .rx_m               (rx1_m),
//    .rx_mode            (rx1_mode),
//    .drpclk             (clk_27M),
//    .txp                (mgtp_tx1_p),
//    .txn                (mgtp_tx1_n),
//    .rxp                (mgtp_rx1_p),
//    .rxn                (mgtp_rx1_n),
//    .pll0clk            (pll0clk),
//    .pll0refclk         (pll0refclk),
//    .pll1clk            (pll1clk),
//    .pll1refclk         (pll1refclk),
//    .control0           (control4),
//    .control1           (control5),
//    .control2           (control6));

//------------------------------------------------------------------------------
// GTP COMMON wrapper
//
// This wrapper is generated by the GT wizard. It contains the two PLLs for the
// GTP Quad.
//

a7gtp_sdi_wrapper_common #(
    .WRAPPER_SIM_GTRESET_SPEEDUP    ("FALSE"))
gtpe2_common_0 (
    .GTGREFCLK0_IN                  (1'b0),
    .GTGREFCLK1_IN                  (1'b0),
    .GTEASTREFCLK0_IN               (1'b0),
    .GTEASTREFCLK1_IN               (1'b0),
    .GTREFCLK0_IN                   (mgtclk_148_5),
    .GTREFCLK1_IN                   (/*mgtclk_148_35*/),
    .GTWESTREFCLK0_IN               (1'b0),
    .GTWESTREFCLK1_IN               (1'b0),
    .PLL0OUTCLK_OUT                 (pll0clk),
    .PLL0OUTREFCLK_OUT              (pll0refclk),
    .PLL0LOCK_OUT                   (pll0lock),
    .PLL0LOCKDETCLK_IN              (clk_27M),
    .PLL0REFCLKLOST_OUT             (),
    .PLL0RESET_IN                   (pll0reset),
    .PLL1OUTCLK_OUT                 (pll1clk),
    .PLL1OUTREFCLK_OUT              (pll1refclk),
    .PLL1LOCK_OUT                   (pll1lock),
    .PLL1LOCKDETCLK_IN              (clk_27M),
    .PLL1REFCLKLOST_OUT             (),
    .PLL1RESET_IN                   (pll1reset),
    .PLL0REFCLKSEL_IN               (3'b001),           //USE GTREFCLK0_IN
    .PLL1REFCLKSEL_IN               (/*3'b010*/3'b001));//USE GTREFCLK0_IN

endmodule

    
