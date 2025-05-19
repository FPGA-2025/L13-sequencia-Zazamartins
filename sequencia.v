module Sequencia (
    input wire clk,
    input wire rst_n,

    input wire setar_palavra,
    input wire [7:0] palavra,

    input wire start,
    input wire bit_in,

    output reg encontrado
);

    reg [7:0] palavra_reg;       // Registra a sequência alvo
    reg [7:0] shift_reg;         // Registrador de deslocamento para os bits recebidos
    reg start_prev;              // Armazena o estado anterior de start para detecção de borda
    reg shift_enable;            // Habilita o deslocamento no registrador

    // Detecção da borda de subida do sinal start
    wire start_rise = start & ~start_prev;

    // Atualiza o registrador da sequência alvo
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            palavra_reg <= 8'b0;
        end else if (setar_palavra) begin
            palavra_reg <= palavra;
        end
    end

    // Lógica principal de controle e deslocamento
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            start_prev <= 1'b0;
            shift_reg <= 8'b0;
            shift_enable <= 1'b0;
            encontrado <= 1'b0;
        end else begin
            start_prev <= start;  // Atualiza o estado anterior de start

            if (start_rise) begin
                // Inicia novo processo de captura
                shift_reg <= 8'b0;
                shift_enable <= 1'b1;
                encontrado <= 1'b0;
            end else if (shift_enable && !encontrado) begin
                // Desloca o novo bit e compara
                shift_reg <= {shift_reg[6:0], bit_in};
                if ({shift_reg[6:0], bit_in} == palavra_reg) begin
                    encontrado <= 1'b1;
                    shift_enable <= 1'b0;
                end
            end
        end
    end

endmodule