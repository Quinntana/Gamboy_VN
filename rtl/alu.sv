module alu_32bit (
    input  logic [31:0] operand_a,
    input  logic [31:0] operand_b,
    input  logic [2:0]  opcode,
    output logic [31:0] result,
    output logic c_flag, // Carry flag
    output logic v_flag  // Overflow flag
);

    // Internal 33-bit signal to capture carry-out during addition/subtraction
    logic [32:0] extended_result;

    always_comb begin
        // Default flag assignments to prevent unintended latches
        c_flag = 1'b0;
        v_flag = 1'b0;
        extended_result = 33'd0;

        case (opcode)
            3'b000: begin // ADD
                extended_result = {1'b0, operand_a} + {1'b0, operand_b};
                result = extended_result[31:0];
                c_flag = extended_result[32];
                // Overflow occurs if operands have same sign, but result sign differs
                v_flag = (operand_a[31] == operand_b[31]) && (operand_a[31] != result[31]);
            end
            
            3'b001: begin // SUBTRACT
                // Subtraction via 2's complement addition: A + (~B) + 1
                extended_result = {1'b0, operand_a} + {1'b0, ~operand_b} + 33'd1;
                result = extended_result[31:0];
                c_flag = extended_result[32];
                // Overflow occurs if operands have different signs, and result sign differs from operand A
                v_flag = (operand_a[31] != operand_b[31]) && (operand_a[31] != result[31]);
            end
            
            3'b010: result = operand_a & operand_b; // Bitwise AND
            3'b011: result = operand_a | operand_b; // Bitwise OR
            3'b100: result = operand_a ^ operand_b; // Bitwise XOR
            
            3'b101: result = operand_a << operand_b[4:0];  // Logical Shift Left
            3'b110: result = operand_a >> operand_b[4:0];  // Logical Shift Right
            3'b111: result = $signed(operand_a) >>> operand_b[4:0]; // Arithmetic Shift Right
            
            default: result = 32'd0;
        endcase
    end

endmodule