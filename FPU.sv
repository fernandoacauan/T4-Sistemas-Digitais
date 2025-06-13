typedef enum bit [3:0] { EXACT, OVEFLOW, UNDERFLOW, INEXACT } eStatus;

/********|********|********|********|********|********|********|********/
/*                                                                     */
/*                           CFPU                                      */
/*                                                                     */
/********|********|********|********|********|********|********|********/

module CFpu
(
  input  logic  [31:0]  m_opA, // expoente com 11 bits e mantissa com 20
  input  logic  [31:0]  m_opB,
  input  logic          m_reset,
  input  logic          m_clk,
  output logic  [31:0]  m_dataOut,
  output eStatus        m_statusOut
);

/********|********|********|********|********|********|********|********/

/* (-1)^s + 1f . 2^e-127 */
function bit [31:0] Somar(input logic [31:0] opA, input logic [31:0] opB);
  static int expDiff = opA[30:20] - opB[30:20]; 
  if(opA[30:20] > opB[30:20])
  begin
      
  end
  
  
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

    if(m_opA[31] ^ m_opB[31]) // Vai ser uma soma pq �e o mesmo sinal
    begin
       Somar(m_opA, m_opB);
    end 
    else 
    begin
       Diminuir(m_opA, m_opB);
    end
end

endmodule
