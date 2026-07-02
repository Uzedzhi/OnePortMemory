`include "MemoryEmulator.v"

`define NUM_OF_TESTS 10
`define WIDTH 10
`define DEPTH 32

module TB();
    reg clock;
    initial begin
        clock = 0;
    end
    reg [`WIDTH - 1:0] tests [0:`NUM_OF_TESTS - 1];

    always begin
        #10; clock = ~clock;
    end

    integer file_ptr;
    reg read;
    reg write;
    reg [$clog2(`DEPTH) - 1:0] addr;
    reg [`WIDTH - 1:0] data_in;
    reg [`WIDTH - 1:0] data_out;

    initial begin
        $dumpfile("simulation.vcd");
        $dumpvars(0, TB);
    end

    initial begin
        $display("read, write, addr, data_in, data_out");
        $monitor("%d, %d, %d, %d, %d",  read,
                                        write,
                                        addr,
                                        data_in,
                                        data_out);

        file_ptr = $fopen("TB.txt", "r");
        if (file_ptr == 0) begin
            $display("Не смог открыть файл тестбенча.");
            $finish;
        end
    end

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

    initial begin: running_tests
        integer status;

        reg t_read;
        reg t_write;
        reg [$clog2(`DEPTH) - 1:0] t_addr;
        reg [`WIDTH - 1:0] t_data_in;

        for (integer i = 0; i < `NUM_OF_TESTS && !$feof(file_ptr); i = i+1) begin
            @(posedge clock);
            status = $fscanf(file_ptr, "%d, %d, %d, %d", t_read, t_write, t_addr, t_data_in);

            read    <= t_read;
            write   <= t_write;
            addr    <= t_addr;
            data_in <= t_data_in;
        end
        #30;

        $fclose(file_ptr);
        $finish;
    end

endmodule