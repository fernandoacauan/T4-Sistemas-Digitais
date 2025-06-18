/********|********|********|********|********|********|********|********/
/*                      TRABALHO IV SD                                 */
/* File:   FPU.sv                                                      */
/* Author: Fernando Acauan                                             */
/*                                                                     */
/********|********|********|********|********|********|********|********/

typedef enum bit [3:0] { EXACT, OVEFLOW, UNDERFLOW, INEXACT } g_eStatus;

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

/* (-1)^s + 1f . 2^e-127 */
function bit [31:0] Somar(input logic [31:0] opA, input logic [31:0] opB);
  int mantA = opA[19:0];
  int mantB = opB[19:0];
  int resultadoExp[10:0];
  if(opA[30:20] > opB[30:20]) begin
    mantB = mantB >> (opA[30:20] - opB[30:20]);
    resultadoExp = opA[30:20];
  end else begin
    mantA = mantA >> (opA[30:20] - opB[30:20]);
    resultadoExp = opB[30:20];
  end

  int somaMant = mantA + mantB;

  if(somaMant[20]) begin 
      somaMant = somaMant >> 1;
  end

  return 0;
endfunction

/********|********|********|********|********|********|********|********/

function bit [31:0] Diminuir(input logic [31:0] opA, input logic [31:0] opB);

endfunction

/********|********|********|********|********|********|********|********/

function bit [31:0] Multiplicar(input logic [31:0] opA, input logic [31:0] opB);
endfunction

/********|********|********|********|********|********|********|********/

always @(posedge m_clk)
 begin
  if(!m_reset)
    begin
      m_dataOut <= 32'b0;
      m_statusOut <= EXACT;
    end

    if(m_opA[31] == m_opB[31]) // Vai ser uma soma pq �e o mesmo sinal
    begin
       m_dataOut <= Somar(m_opA, m_opB);
    end else begin
       m_dataOut <= Diminuir(m_opA, m_opB);
    end
end

endmodule

/********|********|********|********|********|********|********|********/
