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
  output g_eStatus      m_statusOut // enum pra dizer ql o status. tá definido no package de fpu_types.
);

 typedef enum logic [0:0] {CALCULO, SAIDA} eEstado;
 eEstado estado;
 logic [31:0] resultado;
 logic        flag;

/********|********|********|********|********|********|********|********/

function automatic logic [31:0] Somar(input logic [31:0] opA, input logic [31:0] opB, output logic flag);
  logic        [10:0] expA, expB;
  logic signed [10:0] expA_real, expB_real, resultadoExp;
  logic signed [10:0] shift;
  logic        [20:0] mantA, mantB, somaMant;
  logic        [21:0] soma_ext;
  logic               signA, signB;
  int                 zeros_leading;  // os zeros desgracados
  localparam          BIAS = 1023;
  
  signA = opA[31];
  signB = opB[31];
  
  expA = opA[30:20];
  expB = opB[30:20];
  
  expA_real = signed'(expA) - BIAS;
  expB_real = signed'(expB) - BIAS;
  
  mantA = {1'b1, opA[19:0]};
  mantB = {1'b1, opB[19:0]};
  flag = 0;

  if ((expA_real == -1022) || (expB_real == -1022)) begin
     flag = 1;
    return {signA, 11'b0, 20'b0};
  end

  // alinhar os expoentes
  if (expA_real > expB_real) begin
    shift = expA_real - expB_real;
    
    if (shift > 21) begin
      mantB = 0;
      flag = 1;
    end else begin
      for (int i = 0; i < shift; i++) begin
        if (mantB[i]) flag = 1;
      end
      mantB = mantB >> shift;
    end
    resultadoExp = expA_real;

  end else if (expB_real > expA_real) begin
    shift = expB_real - expA_real;
    
    if (shift > 21) begin
      mantA = 0;
      flag = 1;
    end else begin
      for (int i = 0; i < shift; i++) begin
        if (mantA[i]) flag = 1;
      end
      mantA = mantA >> shift;
    end
    resultadoExp = expB_real;

  end else begin
    resultadoExp = expA_real;
  end

  // somar e normalizar o num
  soma_ext = {1'b0, mantA} + {1'b0, mantB};
  
  // se der overflow
  if (soma_ext[21]) begin
    somaMant = soma_ext[21:1];
    flag = flag | soma_ext[0];
    resultadoExp = resultadoExp + 1;
  end 
  // se estiver normalizado
  else if (soma_ext[20]) begin
    somaMant = soma_ext[20:0];
  end 
  // se precisar de normalizacao a esquerda
  else begin
    zeros_leading = 0;
    for (int i = 20; i >= 0; i--) begin
      if (soma_ext[i]) break;
      zeros_leading++;
    end
    
    if (zeros_leading == 21) begin
      somaMant = 0;
      resultadoExp = 0;
    end else begin
      somaMant = soma_ext << zeros_leading;
      resultadoExp = resultadoExp - zeros_leading;
      flag = 1;
    end
  end

  if (resultadoExp > 1023) begin
    return {signA, 11'b11111111111, 20'b0};
  end else if (resultadoExp < -1022) begin
    return {signA, 11'b0, 20'b0};
  end

  return {signA, resultadoExp[10:0] + BIAS, somaMant[19:0]};
endfunction


/********|********|********|********|********|********|********|********/

function automatic logic [31:0] Diminuir(input logic [31:0] opA, input logic [31:0] opB, output logic flag);
  logic        [10:0] expA, expB;
  logic signed [10:0] expA_real, expB_real, resultadoExp;
  logic signed [10:0] shift;
  logic        [20:0] mantA, mantB;
  logic        [21:0] resultadoMant;
  logic               signA, signB, resultadoSign;
  int                 zeros_leading;
  localparam          BIAS = 1023;
  
  signA = opA[31];
  signB = opB[31];
  
  expA = opA[30:20];
  expB = opB[30:20];
  
  expA_real = signed'(expA) - BIAS;
  expB_real = signed'(expB) - BIAS;
  
  mantA = {1'b1, opA[19:0]};
  mantB = {1'b1, opB[19:0]};
  flag = 0;

  // alinhar os expoentes
  if (expA_real > expB_real) begin
    shift = expA_real - expB_real;
    
    if (shift > 21) begin
      mantB = 0;
      flag = 1;
    end else begin
      for (int i = 0; i < shift; i++) begin
        if (mantB[i]) flag = 1;
      end
      mantB = mantB >> shift;
    end
    resultadoExp = expA_real;

  end else if (expB_real > expA_real) begin
    shift = expB_real - expA_real;
    
    if (shift > 21) begin
      mantA = 0;
      flag = 1;
    end else begin
      for (int i = 0; i < shift; i++) begin
        if (mantA[i]) flag = 1;
      end
      mantA = mantA >> shift;
    end
    resultadoExp = expB_real;
    resultadoSign = ~signA;

  end else begin
    resultadoExp = expA_real;
  end

  // subtrair
  if (mantA > mantB) begin
    resultadoMant = {1'b0, mantA} - {1'b0, mantB};
  end else if (mantB > mantA) begin
    resultadoMant = {1'b0, mantB} - {1'b0, mantA};
    resultadoSign = ~resultadoSign;
  end else begin
    return 0;
  end

  // normalizar
  zeros_leading = 0;
  for (int i = 21; i >= 0; i--) begin
    if (resultadoMant[i]) break;
    zeros_leading++;
  end
  
  if (zeros_leading > 0) begin
    resultadoMant = resultadoMant << zeros_leading;
    resultadoExp = resultadoExp - zeros_leading;
    flag = 1;
  end

  if (resultadoExp > 1023) begin
    return {resultadoSign, 11'b11111111111, 20'b0};
  end else if (resultadoExp < -1022) begin
    return {resultadoSign, 11'b0, 20'b0};
  end

  return {resultadoSign, resultadoExp[10:0] + BIAS, resultadoMant[20:1]};
endfunction

/********|********|********|********|********|********|********|********/

always @(posedge m_clk or negedge m_reset) begin
  if (!m_reset) begin
    m_dataOut   <= 32'b0;
    m_statusOut <= EXACT;
    resultado   <= 32'b0;
    flag        <= 1'b0;
    estado      <= CALCULO;
  end else begin
    logic [10:0] expResultado;
    logic        temp_flag;

    case (estado)
      CALCULO: begin
        temp_flag = 1'b0;
        
        // ver que operacao fazer de acordo com os sinais
        if (m_opA[31] == m_opB[31]) begin
          resultado <= Somar(m_opA, m_opB, temp_flag);
        end else begin
          resultado <= Diminuir(m_opA, m_opB, temp_flag);
        end
        
        flag   <= temp_flag;
        estado <= SAIDA;
      end
      
      SAIDA: begin
        m_dataOut   <= resultado;
        expResultado = resultado[30:20];

        // aplicar os status certo
        if (expResultado == 11'b11111111111) begin
          m_statusOut <= OVERFLOW;
        end else if (expResultado == 0 && resultado[19:0] == 0 && flag) begin // necessario pra que qualquer operacao que resulte em 0 nao entrar em underflow
          m_statusOut <= UNDERFLOW;
        end else if (flag) begin
          m_statusOut <= INEXACT;
        end else begin
          m_statusOut <= EXACT;
        end
        estado <= CALCULO;
      end
    endcase
  end
end
endmodule

/********|********|********|********|********|********|********|********/

