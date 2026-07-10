`include "MemoryEmulator.v"

// ----------------Тестбенч для однопоортовой памяти------------------
module TB();
    // // Дамп для waveform
    // initial begin
    //     $dumpfile("simulation.vcd");
    //     $dumpvars(0, TB);
    // end

// -----------clock initializing-----------
    reg clock;
    initial begin
        clock = 0;
    end
    always begin
        #10; clock = ~clock;
    end
// ----------------------------------------

// -----------------------Testing module instantiation-----------------------
    integer AllCorrect = 1;
    reg  read;
    reg  write;
    reg  [$clog2(`DEPTH) - 1:0]  addr;
    reg  [`WIDTH - 1:0]          data_in;
    wire [`WIDTH - 1:0]          data_out;

    memory #(
        .WIDTH(`WIDTH),
        .DEPTH(`DEPTH)
    ) TB_memory (
        .clock(clock),
        .read(read),
        .write(write),
        .addr(addr),
        .data_in(data_in),
        .data_out(data_out)
    );
// ---------------------------------------------------------------------------

// ----------------------------Main Testing-----------------------------------
    initial begin: running_tests

// ------------Запись в массив рандомных чисел-------------
        reg [`WIDTH - 1:0] RandomArray [`DEPTH - 1:0];

        integer Temp;
        if ($value$plusargs("seed=%d", Temp) != 1)
            Temp = 123456;

        for (integer i = 0; i < `DEPTH; i = i + 1) begin
            RandomArray[i] = $random(Temp) % (2 ** `WIDTH);
        end

        // Запись во все ячейки памяти рандомных чисел
        @(negedge clock);

        write   <= 1;
        read    <= 0;
        data_in <= 0;

        for (integer i = 0; i < `DEPTH; i = i + 1) begin
            @(posedge clock);

            addr    <= i;
            data_in <= RandomArray[i];
        end
// ---------------------------------------------------------

// --------------------------ТЕСТ ЧТЕНИЯ----------------------------------------
        @(negedge clock);

        write   <= 0;
        read    <= 1;
        addr    <= 0;
        
        @(posedge clock);
        for (integer i = 1; i < `DEPTH; i = i + 1) begin
            addr <= i;

            @(posedge clock);

            if (data_out !== RandomArray[i - 1]) begin
                $write("%c[1;31m[ОШИБКА]%c[0m при чтении по адресу %1d\n", `ESC, `ESC, i - 1);
                $write("\tОжидал получить %d, а получил %d\n", RandomArray[i - 1], data_out); 
                AllCorrect = 0;
            end
        end
// ------------------------------------------------------------------------------

// --------------------------ТЕСТ ОДНОРЕМЕННОГО ЧТЕНИЯ И ЗАПИСИ--------------------------
        // должно вернуться то значение, которое дали на запись
        // и должно читаться то значение, которое записали
        @(negedge clock);
        write   <= 1;
        read    <= 1;
        addr    <= 0;
        data_in <= 1;

        @(posedge clock);
        for (integer i = 1; i < `DEPTH; i = i + 1) begin
            addr    <= i;
            data_in <= i + 1; // записываем адрес ячейки + 1 (чтобы не было шальных нулей)

            @(posedge clock);
            if (data_out !== i) begin
                $write("%c[1;31m[ОШИБКА]%c[0m при одномвременном записи и чтении (1 проход) по адресу %1d\n", `ESC, `ESC, i);
                $write("\tОжидал прочитать %d, а прочитал %d\n", i, data_out); 
                AllCorrect = 0;
            end
        end
// ---------------------------------------------------------------------------------------

// --------------------------ТЕСТ ПОВТОРНОГО ЧТЕНИЯ----------------------------------------
        @(negedge clock);
        write   <= 0;
        read    <= 1;
        addr    <= 0;
        
        @(posedge clock);
        for (integer i = 1; i < `DEPTH; i = i + 1) begin
            addr <= i;

            @(posedge clock);
            if (data_out !== i) begin
                $write("%c[1;31m[ОШИБКА]%c[0m при одновременном записи и чтении (2 проход) по адресу %1d\n", `ESC, `ESC, i);
                $write("\tОжидал прочитать %d, а прочитал %d\n", i, data_out); 
                AllCorrect = 0;
            end
        end
// ------------------------------------------------------------------------------

        if (AllCorrect) begin
            $display("%c[1;32mВсе тесты пройдены успешно!%c[0m", `ESC, `ESC);
        end
        $finish;
    end
endmodule