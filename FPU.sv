typedef enum bit [3:0] { EXACT, OVEFLOW, UNDERFLOW, INEXACT } eStatus;

/********|********|********|********|********|********|********|********/
/*                                                                     */
/*                           CFPU                                      */
/*                                                                     */
/********|********|********|********|********|********|********|********/
module CFpu
(
  input  logic  [31:0]  m_opA,
  input  logic  [31:0]  m_opB,
  input  logic          m_reset,
  input  logic          m_clk,
  output logic  [31:0]  m_dataOut,
  output eStatus        m_statusOut
);
/********|********|********|********|********|********|********|********/

always @(posedge m_clk)
 begin
  if(!m_reset)
    begin
      m_dataOut <= 32'b0;
      m_statusOut <= EXACT;
    end
end

endmodule
