/********|********|********|********|********|********|********|********/
/*                        TRABALHO IV SD                               */
/* File:   tbFpu.sv                                                    */
/* Author: Fernando Acauan                                             */
/*                                                                     */
/********|********|********|********|********|********|********|********/

`timescale 1ns/1ps
import FPU_types::*;

/********|********|********|********|********|********|********|********/

/********|********|********|********|********|********|********|********/
/*                                                                     */
/*                           TB_FPU                                    */
/*                                                                     */
/********|********|********|********|********|********|********|********/

module tb_CFpu;

  logic [31:0] m_opA;
  logic [31:0] m_opB;
  logic        m_reset;
  logic        m_clk;

  logic [31:0] m_dataOut;
  g_eStatus    m_statusOut;

  CFpu dut (
    .m_opA(m_opA),
    .m_opB(m_opB),
    .m_reset(m_reset),
    .m_clk(m_clk),
    .m_dataOut(m_dataOut),
    .m_statusOut(m_statusOut)
  );

  initial m_clk = 0;
  always #5 m_clk = ~m_clk;
  
  function automatic logic [31:0] ConverterNum(input logic sign, input logic [10:0] exp, input logic [19:0] mant);
    return {sign, exp, mant};
  endfunction

  initial begin
    m_reset = 0; // Ativa reset
    #20;
    m_reset = 1; // Libera reset e inicia operação


    #10;
    m_opA = ConverterNum(0, 11'd127, 20'd0); // +1.0
    m_opB = ConverterNum(0, 11'd127, 20'd0); // +1.0
    #10;

    #10;
    m_opA = ConverterNum(0, 11'd128, 20'd0); // +2.0
    m_opB = ConverterNum(0, 11'd127, 20'd0); // +1.0
    #10;

    #10;
    m_opA = ConverterNum(0, 11'd127, 20'd0);  // +1.0
    m_opB = ConverterNum(1, 11'd127, 20'd0);  // -1.0
    #10;

    #10;
    m_opA = ConverterNum(0, 11'd2046, 20'hFFFFF); // Overflow
    m_opB = ConverterNum(0, 11'd2046, 20'hFFFFF);
    #10;

    #10;
    m_opA = ConverterNum(0, 11'd0, 20'd1); // Underflow
    m_opB = ConverterNum(0, 11'd0, 20'd1);
    #10;

    #10;
    m_opA = ConverterNum(0, 11'd130, 20'hFFFFF); // Inexact - perda de bits no shift
    m_opB = ConverterNum(0, 11'd127, 20'd1);
    #10;

    #10;
    m_opA = ConverterNum(0, 11'd127, 20'h80000); // Soma com carry
    m_opB = ConverterNum(0, 11'd127, 20'h80000);
    #10;

    #10;
    m_opA = ConverterNum(0, 11'd127, 20'h40000); // Subtr com resultado negativo
    m_opB = ConverterNum(0, 11'd127, 20'h80000);
    #10;
    

    #10;
    m_opA = ConverterNum(0, 11'd128, 20'h20000); // Soma normal
    m_opB = ConverterNum(0, 11'd128, 20'h20000);
    #10;
   

    $stop;
  end

endmodule

/********|********|********|********|********|********|********|********/

