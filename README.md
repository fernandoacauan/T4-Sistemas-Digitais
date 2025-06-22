# T4-Sistemas-Digitais
Este projeto implementa uma Unidade de Ponto Flutuante (FPU) que realiza operações de soma e subtração em formato personalizado (1 bit de sinal, 11 bits de expoente, 20 bits de mantissa). O projeto inclui a implementação da FPU, um testbench abrangente com 10 casos de teste e um script de simulação para o ModelSim.

# Fórmula 
- X = ( 8 + ( 2 + 4 + 1 + 0 + 3 + 3 + 1 + 4 + 1 ) % 4 ) = 11
- Y = 31 - 11 = 20

## Conteúdo
Neste repositório você encontrará:

 `FPU.sv`: Módulo principal da FPU, contendo as funções de soma e subtração.

- `fpu_types.sv`: Pacote com a definição do enum para status da operação.

- `tbFPU.sv`: Testbench com 10 casos de teste que cobrem operações básicas, corner cases e situações de erro.

- `sim.do`: Script para automatizar a simulação no ModelSim.

- `wave.do`: Script para configurar o wave no ModelSim.

## Especificação da FPU

- **Formato**:

- Bit 31: Sinal (0 pra positivo e 1 pra negativo)

- Bits 30-20: Expoente (11 bits, o bias é de 1023 ja que é 01111111111)

- Bits 19-0: Mantissa (20 bits, formato 1,f para normalizados)

- **Operações Suportadas**: Soma e subtração.

- **Status de Saída**:

- `EXACT`: Operação exata sem perda de precisão.

- `OVERFLOW`: Resultado excede o maior número representável da FPU.

- `UNDERFLOW`: Resultado é menor que o menor número normalizado.

- `INEXACT`: Operação resultou em perda de precisão.

## Testbench

O testbench contém 10 casos de teste:

# Todos os casos:
![Todos](https://github.com/user-attachments/assets/f12436ee-341c-4d9a-95d0-412752b8ffb3)

# Casos separados

- Caso Um:
![casoUm](https://github.com/user-attachments/assets/a8cadcc2-af28-4152-bae4-7ba1290f3343)
- Caso Dois:
![casoDois](https://github.com/user-attachments/assets/1f17682a-e659-49ec-8e42-29bba5242108)
- Caso Tres:
![casoTres](https://github.com/user-attachments/assets/341b1048-a29e-4498-a38a-135bba6e1e4e)
- Caso Quatro:
![casoQuatro](https://github.com/user-attachments/assets/1787744d-be3e-49c4-8235-2d662f1f5391)
- Caso Cinco:
![CasoCinco](https://github.com/user-attachments/assets/72e35d80-a699-4484-a489-89f79846ed90)
- Caso Seis:
![CasoSeis](https://github.com/user-attachments/assets/1457bc01-c43e-485c-b094-e658cd6b971a)
- Caso Sete:
![casoSete_1](https://github.com/user-attachments/assets/8b658132-9be2-4e8c-bbc2-a6b878d43d25)
- Caso Oito:
![casoOito](https://github.com/user-attachments/assets/2ff568fe-aa95-463d-a465-c1727b5597a3)
- Caso Nove:
![casoNove](https://github.com/user-attachments/assets/dd68e6b6-af7d-4360-b1f4-60a129b07465)
- Caso Dez:
![casoDez](https://github.com/user-attachments/assets/9a5afef9-d1f2-4cab-a88b-6acc18f857cd)

## Resultados Obtidos
A FPU foi implementada com sucesso, apenas com erro no teste 4, falhando em detectar o overflow, interpretando como EXACT. O tratamento de status (EXACT, OVERFLOW, UNDERFLOW, INEXACT) funciona muito bem e foi pensado utilizando um enum. O projeto demonstra a correta manipulação do formato de ponto flutuante personalizado.

## Requisitos
- ModelSim (ou simulador compatível com SystemVerilog).

## Como Executar a Simulação
1. Abra o ModelSim.

2. Crie um novo projeto

3. Adicione os arquivos desse repositório

4. Execute o seguinte comando no terminal: `do sim.do`

- O script `sim.do` compila os arquivos, inicia a simulação e carrega as ondas.

## Espaço Numérico Representável
O maior numero representável é 1,9974368165 * 10^308
O menor numero representavel é 2,472304287 * 10^-308
![Representavel](https://github.com/user-attachments/assets/f0b2bbb6-6aa9-4c30-ab06-2b850fa2f394)
![RepresentavelBin](https://github.com/user-attachments/assets/ec6e17ef-8d2f-4b79-9479-fa9680e92476)

