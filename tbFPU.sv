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
  always #5000 m_clk = ~m_clk;
  
  function automatic logic [31:0] ConverterNum(input logic sign, input logic [10:0] exp_real, input logic [19:0] mant);
    localparam   BIAS = 1023;
    logic [10:0] exp = exp_real + BIAS;
    return {sign, exp, mant};
  endfunction

  initial begin
  m_reset = 0;
  #20 m_reset = 1;
 
  /********|********|********|********|********|********|********|********/
  /*                                                                     */
  /*                           TESTES                                    */
  /*                                                                     */
  /********|********|********|********|********|********|********|********/
  

  // Teste 1: 1.0 + 1.0 = 2.0 (EXACT)
  // Resultado: 01000000000000000000000000000000
  #1;
  m_opA = ConverterNum(0, 0, 20'h00000); /* 1.0 */ m_opB = ConverterNum(0, 0, 20'h00000); /* 1.0 */ @(posedge m_clk); @(posedge m_clk);
  
  // Teste 2: 2.0 + 0.5 = 2.5 (EXACT)
  // Resultado: 01000000000010000000000000000000
  #1;
  m_opA = ConverterNum(0, 1, 20'h00000);  /* 2.0 */ m_opB = ConverterNum(0, -1, 20'h00000); /* 0.5 */ @(posedge m_clk); @(posedge m_clk);
  
  // Teste 3: 1.0 + (-1.0) = 0.0 (EXACT)
  // Resultado: 00000000000000000000000000000000
  #1;
  m_opA = ConverterNum(0, 0, 20'h00000); /* 1.0 */ m_opB = ConverterNum(1, 0, 20'h00000); /* -1.0 */ @(posedge m_clk); @(posedge m_clk);
  
  // Teste 4: Overflow (MAX + MAX) (nao ta dando certo :\)
  // Resultado: 01111111111100000000000000000000
  #1;
  m_opA = ConverterNum(0, 1023, 20'hFFFFF); /* ~2^1024 */ m_opB = ConverterNum(0, 1023, 20'hFFFFF); /* ~2^1024 */ @(posedge m_clk); @(posedge m_clk);
  
  // Teste 5: Underflow (MIN + MIN)
  // Resultado: 00000000000000000000000000000000
  #1;
  m_opA = ConverterNum(0, -1022, 20'h00001); /* ~2^-1022 */ m_opB = ConverterNum(0, -1022, 20'h00001); /* ~2^-1022 */ @(posedge m_clk); @(posedge m_clk);
  
  // Teste 6: Inexact (2047.999... + 1.000...1)
  // Resultado: 01000000101000000000000111111111 (INEXACT)
  #1;
  m_opA = ConverterNum(0, 10, 20'hFFFFF); /* 2047.999... */ m_opB = ConverterNum(0, 0, 20'h00001);  /* 1.000...1 */ @(posedge m_clk); @(posedge m_clk);
  
  // Teste 7: Soma com carry (1.5 + 1.5 = 3.0) (EXACT)
  // Resultado: 01000000000010000000000000000000
   #1;
   m_opA = ConverterNum(0, 0, 20'h80000); /* 1.5 */ m_opB = ConverterNum(0, 0, 20'h80000); /* 1.5 */ @(posedge m_clk); @(posedge m_clk);
  
  // Teste 8: Subtração com negativo (1.0 - 1.5 = -0.5  (INEXACT)
  // Resultado: 10111111111000000000000000000000
   #1;
   m_opA = ConverterNum(0, 0, 20'h00000); /* 1.0 */ m_opB = ConverterNum(1, 0, 20'h80000); /* -1.5 */ @(posedge m_clk); @(posedge m_clk);
  
  // Teste 9: Soma fracionária exata (2.25 + 0.75 = 3.0) (EXACT)
  // Resultado: 01000000000010000000000000000000
     #1;
     m_opA = ConverterNum(0, 1, 20'h20000);  /* 2.25 */ m_opB = ConverterNum(0, -1, 20'h80000); /* 0.75 */ @(posedge m_clk); @(posedge m_clk);
  
  // Teste 10: Identidade (a - a = 0) (EXACT)
  // Resultado: 00000000000000000000000000000000
   #1;
   m_opA = ConverterNum(0, 3, 20'hAAAAA); /* Valor arbitario */ m_opB = ConverterNum(1, 3, 20'hAAAAA); /* -mesmo valor */ @(posedge m_clk); @(posedge m_clk);
  end
endmodule

/********|********|********|********|********|********|********|********/

