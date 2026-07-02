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

    always @(posedge clock) begin
        if (write) begin // запись
            ram[addr] <= data_in;
        end

        if (read & write) begin // чтение и запись одновременно
            data_out <= data_in;
            ram[addr] <= data_in;
        end else if (read & !write) begin // только чтение
            data_out <= ram[addr];
        end
    end
endmodule
