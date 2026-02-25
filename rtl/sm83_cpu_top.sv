module riscv_core (
    input  logic clk,
    input  logic reset
);

    // Internal bus declarations
    logic [31:0] pc_current, pc_next, instruction;
    logic [31:0] read_data1, read_data2, write_data;
    logic [31:0] alu_result, mem_read_data;
    logic [31:0] imm_extended;
    
    // Control signals
    logic reg_write, mem_read, mem_write, alu_src, branch;
    logic [3:0] alu_control;

    // Module Instantiations
    program_counter pc_inst (
        .clk(clk), .reset(reset), .pc_in(pc_next), .pc_out(pc_current)
    );

    instruction_memory imem_inst (
        .address(pc_current), .instruction(instruction)
    );

    control_unit ctrl_inst (
        .opcode(instruction[6:0]), .funct3(instruction[14:12]), 
        .funct7(instruction[31:25]), .reg_write(reg_write), 
        .alu_src(alu_src), .mem_read(mem_read), .mem_write(mem_write)
        // Additional control signals mapped here
    );

    register_file reg_inst (
        .clk(clk), .reg_write(reg_write), 
        .read_reg1(instruction[19:15]), .read_reg2(instruction[24:20]), 
        .write_reg(instruction[11:7]), .write_data(write_data), 
        .read_data1(read_data1), .read_data2(read_data2)
    );

    // ALU Source Multiplexer
    logic [31:0] alu_operand_b;
    assign alu_operand_b = alu_src ? imm_extended : read_data2;

    alu alu_inst (
        .operand_a(read_data1), .operand_b(alu_operand_b), 
        .control(alu_control), .result(alu_result), .zero(zero_flag)
    );

    data_memory dmem_inst (
        .clk(clk), .mem_write(mem_write), .mem_read(mem_read), 
        .address(alu_result), .write_data(read_data2), 
        .read_data(mem_read_data)
    );

    // Write-Back Multiplexer
    assign write_data = mem_read ? mem_read_data : alu_result;

endmodule