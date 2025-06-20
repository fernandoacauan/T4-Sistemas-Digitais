/********|********|********|********|********|********|********|********/
/*                        TRABALHO IV SD                               */
/* File:   FPU.sv                                                      */
/* Author: Fernando Acauan                                             */
/*                                                                     */
/********|********|********|********|********|********|********|********/
/*                        FORMULA                                      */
/* X = ( 8 + ( 2 + 4 + 1 + 0 + 3 + 3 + 1 + 4 + 1 ) % 4 ) = 11          */
/* Y = 31 - 11(X) = 20                                                 */
/*                                                                     */
/********|********|********|********|********|********|********|********/
import FPU_types::*;
`timescale 1ns/1ps
/********|********|********|********|********|********|********|********/
/*                                                                     */
/*                           FPU                                       */
/*                                                                     */
/********|********|********|********|********|********|********|********/

module CFpu
(
  input  logic  [31:0]  m_opA, // expoente com 11 bits e mantissa com 20
  input  logic  [31:0]  m_opB,
  input  logic          m_reset,
  input  logic          m_clk,
  output logic  [31:0]  m_dataOut,
  output g_eStatus      m_statusOut
);

/********|********|********|********|********|********|********|********/

function automatic logic [31:0] Somar(input logic [31:0] opA, input logic [31:0] opB, output logic flag);
  logic signed [10:0] expA, expB, resultadoExp;
  logic        [19:0] mantA, mantB;
  logic        [20:0] somaMant;
  logic               signA, signB;
  logic signed [10:0] shift;

  signA = opA[31];
  signB = opB[31];
  expA  = opA[30:20];
  expB  = opB[30:20];
  mantA = opA[19:0];
  mantB = opB[19:0];
  flag = 0;

  if (expA > expB) begin
    shift = expA - expB; // ve quantos shift precisa pro menor expoente

    for (int i = 0; i < shift; i++) begin
      if (mantB[i]) flag = 1;
    end

    mantB        = mantB >> shift;
    resultadoExp = expA;

  end else begin
    shift = expB - expA;

    for (int i = 0; i < shift; i++) begin
      if (mantA[i]) flag = 1;
    end

    mantA        = mantA >> shift;
    resultadoExp = expB;
  end

  somaMant = mantA + mantB;

  // ve se tem carry out
  if (somaMant[20]) begin
    if (somaMant[0]) flag = 1; // flag pra dizer que teve perca de precisao
    somaMant     = somaMant >> 1; // tem que corrigir a cagad* dando shift pra direita
    resultadoExp = resultadoExp + 1; // corrige o expoente ja que teve que fazer o shift
  end

  return {signA, resultadoExp[10:0], somaMant[19:0]};
endfunction


/********|********|********|********|********|********|********|********/

function automatic logic [31:0] Diminuir(input logic [31:0] opA, input logic [31:0] opB, output logic flag);
  logic signed [10:0] expA, expB, resultadoExp;
  logic        [19:0] mantA, mantB;
  logic signed [20:0] resultadoMant;
  logic               signA, signB, resultadoSign;
  logic signed [10:0] shift;

  signA = opA[31];
  signB = opB[31];
  expA  = opA[30:20];
  expB  = opB[30:20];
  mantA = opA[19:0];
  mantB = opB[19:0];
  flag = 0;

  if (expA > expB) begin
    shift = expA - expB;

    for (int i = 0; i < shift; i++) begin
      if (mantB[i]) flag = 1;
    end

    mantB        = mantB >> shift;
    resultadoExp = expA;

  end else begin
    shift = expB - expA;

    for (int i = 0; i < shift; i++) begin
      if (mantA[i]) flag = 1;
    end

    mantA        = mantA >> shift;
    resultadoExp = expB;
  end

  resultadoMant = mantA - mantB;
  resultadoSign = signA;

  if (resultadoMant < 0) begin
    resultadoMant = -resultadoMant; // deixa a mantissa positiva
    resultadoSign = ~resultadoSign; // ajusta o sinal
  end

  while ((resultadoMant[20] == 0) && (resultadoMant != 0) && (resultadoExp > 0)) begin
    if (resultadoMant[19] == 1) flag = 1; // perda de precisao (bit perdido no shift left)
    resultadoMant = resultadoMant << 1; // normaliza a esquerda para restaurar o msb
    resultadoExp  = resultadoExp - 1;
  end

  return {resultadoSign, resultadoExp[10:0], resultadoMant[19:0]};
endfunction

/********|********|********|********|********|********|********|********/

always @(posedge m_clk)
begin
  if (!m_reset) begin
    m_dataOut   <= 32'b0;
    m_statusOut <= EXACT;
  end else begin
    logic [31:0] resultado;
    logic flag;
    logic [10:0] expResultado;

    // se os sinais sao iguais entao vai ter uma soma
    if (m_opA[31] == m_opB[31]) begin
      resultado = Somar(m_opA, m_opB, flag);
    end else begin
      resultado = Diminuir(m_opA, m_opB, flag);
    end

    m_dataOut <= resultado;
    expResultado = resultado[30:20];

    if (expResultado > 11'b11111111111) begin
      m_statusOut <= OVERFLOW;
    end else if (expResultado == 0) begin
      m_statusOut <= UNDERFLOW;
    end else if (flag) begin
      m_statusOut <= INEXACT;
    end else begin
      m_statusOut <= EXACT;
    end
  end
end
endmodule

/********|********|********|********|********|********|********|********/
