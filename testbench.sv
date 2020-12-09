
`include "includes.svh"
module testbench;

timeunit 1ns/1ps;
    initial
    //shall print %t with scaled in ns (-9), with 2 precision digits, and would print the " ns" string
        $timeformat(-9, 2, " ns", 20);

    logic clk;
    always #5 clk <= ~clk;

    wire data_inout_dut;
    logic [`DATA_LEN - 1 : 0]bit_out_dut;
    logic bidir_write_to_dut;
    logic data_in_dut;
    logic data_out_dut;

    logic [`DATA_LEN - 1 : 0]test_data;
    logic [`DATA_LEN - 1 : 0]test_data_out;

    assign data_out_dut = data_inout_dut;
    assign test_data = '1;
    assign data_inout_dut = (bidir_write_to_dut == 1'b1) ? data_in_dut : 1'bZ;
    
    task switch_to_write();
        bidir_write_to_dut = 1'b1;    
    endtask

    task switch_to_read();
       bidir_write_to_dut = 1'b0; 
    endtask

    task wait_n_clk_cycles(int n_cycles);
        for (int i = 0; i < n_cycles; i++) begin
            @(posedge clk);
            @(negedge clk);
        end

        $display("time is %0t after waiting", $time);
    endtask

    task send_startbit();
        @(negedge clk);
        data_in_dut <= 1;
    endtask

    /* sends a command to the DUT */
    task send_command(ctrl_cmd_t cmd);
        for(int i = `CMD_LEN - 1; i >= 0; i--) begin
            @(negedge clk);
            data_in_dut <= cmd[i];
            $display("wrote command bit %b at %0t", cmd[i], $time);
        end
        @(negedge clk);
        data_in_dut <= 0;
        $display("time is %0t after command", $time);
    endtask

    task send_data(logic [`DATA_LEN - 1 : 0]data);
        for(int i = `DATA_LEN - 1; i >= 0; i--) begin
            @(negedge clk);
            data_in_dut <= data[i];
            $display("wrote data bit %b at %0t", data[i], $time);
        end
        @(negedge clk);
        data_in_dut <= 0; 
        $display("time is %0t after data", $time);
    endtask

    task automatic receive_data(ref logic [`DATA_LEN - 1 : 0]data);
        for(int i = `DATA_LEN - 1; i >= 0; i--) begin
            @(negedge clk);
            data[i] = data_inout_dut; 
            $display("got data bit %b at %0t", data[i], $time);
        end
        @(negedge clk);
        $display("time is %0t after data", $time);
    endtask

    ctrl_cmd_t next_cmd;

    serial_ctrl ser_ctrl_dut(
        .clk(clk),
        .data_inout(data_inout_dut),
        .bit_out(bit_out_dut)
    );

    initial begin
        clk <= 0;
        #20;
        $monitor("data_in_dut = %b", data_in_dut);
        $monitor("ser_ctrl_cmd_reg = %b", ser_ctrl_dut.cmd_reg);
        switch_to_write();
        send_startbit();
        send_command(RESET_CMD);
        wait_n_clk_cycles(3);
        assert (ser_ctrl_dut.curr_state == RESET_ST) else $error("fehler reset at %0t", $time);
        wait_n_clk_cycles(1);
        send_startbit();
        send_command(START_RCV_CMD);
        wait_n_clk_cycles(1);
        assert (ser_ctrl_dut.curr_state == RCV_DATA_ST) else $error("fehler receive at %0t", $time);
        send_data(test_data);
        wait_n_clk_cycles(1);
        send_startbit();
        send_command(UPDATE_CMD);
        wait_n_clk_cycles(3);
        assert (ser_ctrl_dut.curr_state == UPDATE_ST) else $error("fehler update at %0t", $time);
        wait_n_clk_cycles(1);
        send_startbit();
        send_command(START_SND_CMD);
        switch_to_read();
        wait_n_clk_cycles(2);
        assert (ser_ctrl_dut.curr_state == SND_DATA_ST) else $error("fehler update at %0t", $time);
        receive_data(test_data_out);
        assert (test_data == test_data_out) else $error("datenlesefehler! erwartet: %b bekommen: %b", test_data, test_data_out);
    end

endmodule





