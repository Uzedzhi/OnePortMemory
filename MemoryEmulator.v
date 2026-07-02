// ==============Однопортовая памяти============================
// PARAMETERS:  DEPTH       - кол-во строк памяти
//              WIDTH       - ширина строки памяти
// IN:          clock       - тактовый сигнал
//              read        - флаг включения чтения
//              write       - флаг включения записи
//              addr        - адрес куда нужно записать data_in
//              data_in     - входные данные
// OUT:         data_out    - выходная строка памяти
// ===============================================================
module memory #(
    parameter DEPTH     = 32,
    parameter WIDTH     = 10,
    parameter ADDR_W    = $clog2(DEPTH)
)(
    input  clock,
    input  read,
    input  write,
    input  [ADDR_W - 1:0] addr,         
    input  [WIDTH  - 1:0] data_in,
    output reg [WIDTH  - 1:0] data_out
);
    // ram - внутренняя память модуля
    reg [WIDTH - 1:0] ram [0:DEPTH - 1];

    // много always блоков каждый проверяющий что адрес совпадает 
    // со своим номером и тогда в память записывается именно по этому номеру
    generate
        for (genvar i = 0; i < DEPTH; i = i+1) begin
            always @(posedge clock) begin
                if (write & addr == i) begin
                    ram[i] <= data_in;
                end
            end
        end
    endgenerate

    // далее не нужно волноваться о записи, она запишется автоматически
    // в одном из многих блоков сверху
    always @(posedge clock) begin
        if (read & write) begin // чтение и запись одновременно
            data_out <= data_in;
        end else if (read & !write) begin // только чтение
            data_out <= ram[addr];
        end
    end
endmodule
