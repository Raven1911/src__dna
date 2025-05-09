`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/06/2025 09:07:38 PM
// Design Name: 
// Module Name: DNA_SoC
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module DNA_SoC#()(
    input clk,
    input resetn,
    output trap,

    //port uart0
    input  wire rx0,
    output wire tx0,

    //port spi0
    output                          spi0_clk,
    output                          spi0_mosi,
    input                           spi0_miso,
    output     [1:0]                spi0_ss_n
);
    //config axi interconnect
    parameter NUM_SLAVES = 6;

    //config cpu
    parameter [ 0:0] ENABLE_COUNTERS = 1;
    parameter [ 0:0] ENABLE_COUNTERS64 = 1;
    parameter [ 0:0] ENABLE_REGS_16_31 = 1;
    parameter [ 0:0] ENABLE_REGS_DUALPORT = 1;
    parameter [ 0:0] TWO_STAGE_SHIFT = 1;
    parameter [ 0:0] BARREL_SHIFTER = 0;
    parameter [ 0:0] TWO_CYCLE_COMPARE = 0;
    parameter [ 0:0] TWO_CYCLE_ALU = 0;
    parameter [ 0:0] COMPRESSED_ISA = 0;
    parameter [ 0:0] CATCH_MISALIGN = 1;
    parameter [ 0:0] CATCH_ILLINSN = 1;
    parameter [ 0:0] ENABLE_PCPI = 0;
    parameter [ 0:0] ENABLE_MUL = 1;
    parameter [ 0:0] ENABLE_FAST_MUL = 0;
    parameter [ 0:0] ENABLE_DIV = 1;
    parameter [ 0:0] ENABLE_IRQ = 0;
    parameter [ 0:0] ENABLE_IRQ_QREGS = 1;
    parameter [ 0:0] ENABLE_IRQ_TIMER = 1;
    parameter [ 0:0] ENABLE_TRACE = 0;
    parameter [ 0:0] REGS_INIT_ZERO = 1;
    parameter [31:0] MASKED_IRQ = 32'h 0000_0000;
    parameter [31:0] LATCHED_IRQ = 32'h ffff_ffff;
    parameter [31:0] PROGADDR_RESET = 32'h 0100_0000;
    parameter [31:0] PROGADDR_IRQ = 32'h 0000_0010;
    parameter [31:0] STACKADDR = 32'h 0000_4000;

    //config imem and dmem
    parameter I_MEM_SIZE = 4; // 16KB ROM
    parameter D_MEM_SIZE = 4; // 16KB SRAM
    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 32;

    //config spi
    parameter NSlave = 2;

    // AXI signals from picorv32_axi
    wire        cpu_awvalid, cpu_awready;
    wire [31:0] cpu_awaddr;
    wire [ 2:0] cpu_awprot;
    wire        cpu_wvalid, cpu_wready;
    wire [31:0] cpu_wdata;
    wire [ 3:0] cpu_wstrb;
    wire        cpu_bvalid, cpu_bready;
    wire        cpu_arvalid, cpu_arready;
    wire [31:0] cpu_araddr;
    wire [ 2:0] cpu_arprot;
    wire        cpu_rvalid, cpu_rready;
    wire [31:0] cpu_rdata;

    // address line 
    wire [31:0] s_mem_awaddr;
    wire [31:0] s_mem_araddr;

    // AXI signals to dmem_axi_lite//////////////////slave 0/////////////////////
    wire        dmem_awvalid, dmem_awready;
    wire [ 2:0] dmem_awprot;
    wire        dmem_wvalid, dmem_wready;
    wire [31:0] dmem_wdata;
    wire [ 3:0] dmem_wstrb;
    wire        dmem_bvalid, dmem_bready;
    wire        dmem_arvalid, dmem_arready;
    wire [ 2:0] dmem_arprot;
    wire        dmem_rvalid, dmem_rready;
    wire [31:0] dmem_rdata;

    // AXI signals to imem_axi_lite//////////////////slave 1/////////////////////
    wire        imem_awvalid;
    wire        imem_awready = 1'b0; // imem is read-only, so awready is always 0
    wire [ 2:0] imem_awprot;
    wire        imem_wvalid;
    wire        imem_wready = 1'b0;  // imem is read-only, so wready is always 0
    wire [31:0] imem_wdata;
    wire [ 3:0] imem_wstrb;
    wire        imem_bvalid = 1'b0;  // imem is read-only, so bvalid is always 0
    wire        imem_bready;
    wire        imem_arvalid, imem_arready;
    wire [ 2:0] imem_arprot;
    wire        imem_rvalid, imem_rready;
    wire [31:0] imem_rdata;

    // AXI signals to uart0_axi_lite//////////////////slave 2/////////////////////
    wire        uart0_awvalid, uart0_awready;
    wire [ 2:0] uart0_awprot;
    wire        uart0_wvalid, uart0_wready;
    wire [31:0] uart0_wdata;
    wire [ 3:0] uart0_wstrb;
    wire        uart0_bvalid, uart0_bready;
    wire        uart0_arvalid, uart0_arready;
    wire [ 2:0] uart0_arprot;
    wire        uart0_rvalid, uart0_rready;
    wire [31:0] uart0_rdata;

    // AXI signals to spi0_axi_lite//////////////////slave 3/////////////////////
    wire        spi0_awvalid, spi0_awready;
    wire [ 2:0] spi0_awprot;
    wire        spi0_wvalid, spi0_wready;
    wire [31:0] spi0_wdata;
    wire [ 3:0] spi0_wstrb;
    wire        spi0_bvalid, spi0_bready;
    wire        spi0_arvalid, spi0_arready;
    wire [ 2:0] spi0_arprot;
    wire        spi0_rvalid, spi0_rready;
    wire [31:0] spi0_rdata;

    // AXI signals to mem_dna//////////////////slave 4/////////////////////
    wire        dna_mem_awvalid, dna_mem_awready;
    wire [ 2:0] dna_mem_awprot;
    wire        dna_mem_wvalid, dna_mem_wready;
    wire [31:0] dna_mem_wdata;
    wire [ 3:0] dna_mem_wstrb;
    wire        dna_mem_bvalid, dna_mem_bready;
    wire        dna_mem_arvalid, dna_mem_arready;
    wire [ 2:0] dna_mem_arprot;
    wire        dna_mem_rvalid, dna_mem_rready;
    wire [31:0] dna_mem_rdata;

    // AXI signals to ip_dna//////////////////slave 5/////////////////////
    wire        dna_ip_awvalid, dna_ip_awready;
    wire [ 2:0] dna_ip_awprot;
    wire        dna_ip_wvalid, dna_ip_wready;
    wire [31:0] dna_ip_wdata;
    wire [ 3:0] dna_ip_wstrb;
    wire        dna_ip_bvalid, dna_ip_bready;
    wire        dna_ip_arvalid, dna_ip_arready;
    wire [ 2:0] dna_ip_arprot;
    wire        dna_ip_rvalid, dna_ip_rready;
    wire [31:0] dna_ip_rdata;

    // Instantiate picorv32_axi
    picorv32_axi #(
        .ENABLE_COUNTERS     (ENABLE_COUNTERS     ),
        .ENABLE_COUNTERS64   (ENABLE_COUNTERS64   ),
        .ENABLE_REGS_16_31   (ENABLE_REGS_16_31   ),
        .ENABLE_REGS_DUALPORT(ENABLE_REGS_DUALPORT),
        .TWO_STAGE_SHIFT     (TWO_STAGE_SHIFT     ),
        .BARREL_SHIFTER      (BARREL_SHIFTER      ),
        .TWO_CYCLE_COMPARE   (TWO_CYCLE_COMPARE   ),
        .TWO_CYCLE_ALU       (TWO_CYCLE_ALU       ),
        .COMPRESSED_ISA      (COMPRESSED_ISA      ),
        .CATCH_MISALIGN      (CATCH_MISALIGN      ),
        .CATCH_ILLINSN       (CATCH_ILLINSN       ),
        .ENABLE_PCPI         (ENABLE_PCPI         ),
        .ENABLE_MUL          (ENABLE_MUL          ),
        .ENABLE_FAST_MUL     (ENABLE_FAST_MUL     ),
        .ENABLE_DIV          (ENABLE_DIV          ),
        .ENABLE_IRQ          (ENABLE_IRQ          ),
        .ENABLE_IRQ_QREGS    (ENABLE_IRQ_QREGS    ),
        .ENABLE_IRQ_TIMER    (ENABLE_IRQ_TIMER    ),
        .ENABLE_TRACE        (ENABLE_TRACE        ),
        .REGS_INIT_ZERO      (REGS_INIT_ZERO      ),
        .MASKED_IRQ          (MASKED_IRQ          ),
        .LATCHED_IRQ         (LATCHED_IRQ         ),
        .PROGADDR_RESET      (PROGADDR_RESET      ),
        .PROGADDR_IRQ        (PROGADDR_IRQ        ),
        .STACKADDR           (STACKADDR           )
    ) cpu (
        .clk(clk),
        .resetn(resetn),
        .trap(trap),
        .mem_axi_awvalid(cpu_awvalid),
        .mem_axi_awready(cpu_awready),
        .mem_axi_awaddr(cpu_awaddr),
        .mem_axi_awprot(cpu_awprot),
        .mem_axi_wvalid(cpu_wvalid),
        .mem_axi_wready(cpu_wready),
        .mem_axi_wdata(cpu_wdata),
        .mem_axi_wstrb(cpu_wstrb),
        .mem_axi_bvalid(cpu_bvalid),
        .mem_axi_bready(cpu_bready),
        .mem_axi_arvalid(cpu_arvalid),
        .mem_axi_arready(cpu_arready),
        .mem_axi_araddr(cpu_araddr),
        .mem_axi_arprot(cpu_arprot),
        .mem_axi_rvalid(cpu_rvalid),
        .mem_axi_rready(cpu_rready),
        .mem_axi_rdata(cpu_rdata),
        .irq(32'h0), // Chưa dùng IRQ
        .eoi()       // Chưa dùng IRQ
    );

    // Instantiate axi_lite_interconnect
    axi_lite_interconnect #(
        .NUM_SLAVES(NUM_SLAVES),
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) axi_bus_interconnect_unit (
        .resetn(resetn),
        
        // Master Interface (to CPU)
        .i_m_axi_awvalid(cpu_awvalid),
        .o_m_axi_awready(cpu_awready),
        .i_m_axi_awaddr(cpu_awaddr),
        .i_m_axi_awprot(cpu_awprot),
        .i_m_axi_wvalid(cpu_wvalid),
        .o_m_axi_wready(cpu_wready),
        .i_m_axi_wdata(cpu_wdata),
        .i_m_axi_wstrb(cpu_wstrb),
        .o_m_axi_bvalid(cpu_bvalid),
        .i_m_axi_bready(cpu_bready),
        .i_m_axi_arvalid(cpu_arvalid),
        .o_m_axi_arready(cpu_arready),
        .i_m_axi_araddr(cpu_araddr),
        .i_m_axi_arprot(cpu_arprot),
        .o_m_axi_rvalid(cpu_rvalid),
        .i_m_axi_rready(cpu_rready),
        .o_m_axi_rdata(cpu_rdata),

        // Slave Interfaces [5: dna_ip, 4: dna_mem, 3: spi0, 2: uart0, 1: imem, 0: dmem]
        .o_s_axi_awaddr(s_mem_awaddr),
        .o_s_axi_awvalid({dna_ip_awvalid, dna_mem_awvalid, spi0_awvalid, uart0_awvalid, imem_awvalid, dmem_awvalid}),
        .i_s_axi_awready({dna_ip_awready, dna_mem_awready, spi0_awready, uart0_awready, imem_awready, dmem_awready}),
        .o_s_axi_awprot({dna_ip_awprot, dna_mem_awprot, spi0_awprot, uart0_awprot, imem_awprot, dmem_awprot}),
        .o_s_axi_wdata({dna_ip_wdata, dna_mem_wdata, spi0_wdata, uart0_wdata, imem_wdata, dmem_wdata}),
        .o_s_axi_wstrb({dna_ip_wstrb, dna_mem_wstrb, spi0_wstrb, uart0_wstrb, imem_wstrb, dmem_wstrb}),
        .o_s_axi_wvalid({dna_ip_wvalid, dna_mem_wvalid, spi0_wvalid, uart0_wvalid, imem_wvalid, dmem_wvalid}),
        .i_s_axi_wready({dna_ip_wready, dna_mem_wready, spi0_wready, uart0_wready, imem_wready, dmem_wready}),
        .i_s_axi_bvalid({dna_ip_bvalid, dna_mem_bvalid, spi0_bvalid, uart0_bvalid, imem_bvalid, dmem_bvalid}),
        .o_s_axi_bready({dna_ip_bready, dna_mem_bready, spi0_bready, uart0_bready, imem_bready, dmem_bready}),
        .o_s_axi_araddr(s_mem_araddr),
        .o_s_axi_arvalid({dna_ip_arvalid, dna_mem_arvalid, spi0_arvalid, uart0_arvalid, imem_arvalid, dmem_arvalid}),
        .i_s_axi_arready({dna_ip_arready, dna_mem_arready, spi0_arready, uart0_arready, imem_arready, dmem_arready}),
        .o_s_axi_arprot({dna_ip_arprot, dna_mem_arprot, spi0_arprot, uart0_arprot, imem_arprot, dmem_arprot}),
        .i_s_axi_rdata({dna_ip_rdata, dna_mem_rdata, spi0_rdata, uart0_rdata, imem_rdata, dmem_rdata}),
        .i_s_axi_rvalid({dna_ip_rvalid, dna_mem_rvalid, spi0_rvalid, uart0_rvalid, imem_rvalid, dmem_rvalid}),
        .o_s_axi_rready({dna_ip_rready, dna_mem_rready, spi0_rready, uart0_rready, imem_rready, dmem_rready})
    );

    // Instantiate dmem_axi_lite (Slave 0)
    dmem_axi_lite #(
        .MEM_SIZE(D_MEM_SIZE), // 16KB
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) dmem_cpu (
        .clk(clk),
        .resetn(resetn),
        .i_axi_awvalid(dmem_awvalid),
        .o_axi_awready(dmem_awready),
        .i_axi_awaddr(s_mem_awaddr),
        .i_axi_wvalid(dmem_wvalid),
        .o_axi_wready(dmem_wready),
        .i_axi_wdata(dmem_wdata),
        .i_axi_wstrb(dmem_wstrb),
        .o_axi_bvalid(dmem_bvalid),
        .i_axi_bready(dmem_bready),
        .i_axi_arvalid(dmem_arvalid),
        .o_axi_arready(dmem_arready),
        .i_axi_araddr(s_mem_araddr),
        .o_axi_rvalid(dmem_rvalid),
        .i_axi_rready(dmem_rready),
        .o_axi_rdata(dmem_rdata)
    );

    // Instantiate imem_axi_lite (Slave 1, read-only)
    imem_axi_lite #(
        .MEM_SIZE(I_MEM_SIZE), // 16KB
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .PROGADDR_RESET(PROGADDR_RESET)
    ) imem_cpu (
        .clk(clk),
        .resetn(resetn),
        // Read-only (imem không cần write channels)
        .i_axi_arvalid(imem_arvalid),
        .o_axi_arready(imem_arready),
        .i_axi_araddr(s_mem_araddr),
        .o_axi_rvalid(imem_rvalid),
        .i_axi_rready(imem_rready),
        .o_axi_rdata(imem_rdata)
    );

    // Instantiate uart0_axi_lite (Slave 2)
    uart_axi_lite #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_DEPTH_BIT(8)
    ) uart0 (
        .clk(clk),
        .resetn(resetn),
        .i_axi_awvalid(uart0_awvalid),
        .o_axi_awready(uart0_awready),
        .i_axi_awaddr(s_mem_awaddr),
        .i_axi_wvalid(uart0_wvalid),
        .o_axi_wready(uart0_wready),
        .i_axi_wdata(uart0_wdata),
        .i_axi_wstrb(uart0_wstrb),
        .o_axi_bvalid(uart0_bvalid),
        .i_axi_bready(uart0_bready),
        .i_axi_arvalid(uart0_arvalid),
        .o_axi_arready(uart0_arready),
        .i_axi_araddr(s_mem_araddr),
        .o_axi_rvalid(uart0_rvalid),
        .i_axi_rready(uart0_rready),
        .o_axi_rdata(uart0_rdata),
        .tx(tx0),
        .rx(rx0)
    );

    // Instantiate Spi0_axi_lite (Slave 3)
    Spi_axi_lite_core #(
        .NSlave(NSlave),
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) spi0 (
        .clk(clk),
        .resetn(resetn),
        .i_axi_awvalid(spi0_awvalid),
        .o_axi_awready(spi0_awready),
        .i_axi_awaddr(s_mem_awaddr),
        .i_axi_wvalid(spi0_wvalid),
        .o_axi_wready(spi0_wready),
        .i_axi_wdata(spi0_wdata),
        .i_axi_wstrb(spi0_wstrb),
        .o_axi_bvalid(spi0_bvalid),
        .i_axi_bready(spi0_bready),
        .i_axi_arvalid(spi0_arvalid),
        .o_axi_arready(spi0_arready),
        .i_axi_araddr(s_mem_araddr),
        .o_axi_rvalid(spi0_rvalid),
        .i_axi_rready(spi0_rready),
        .o_axi_rdata(spi0_rdata),
        .spi_clk(spi0_clk),
        .spi_mosi(spi0_mosi),
        .spi_miso(spi0_miso),
        .spi_ss_n(spi0_ss_n)
    );

    // wire mem dna
    wire [DATA_WIDTH-1:0] ref_32_i;
    wire [DATA_WIDTH-1:0] read_32_i;
    wire                  W_matrix;

    wire [ADDR_WIDTH-1:0] addr_ref_o;
    wire [ADDR_WIDTH-1:0] addr_read_o;

    wire [ADDR_WIDTH-1:0] addr_matrix_o;
    wire [DATA_WIDTH-1:0] dout_matrix0;
    wire [DATA_WIDTH-1:0] dout_matrix1;
    wire [DATA_WIDTH-1:0] dout_matrix2;
    wire [DATA_WIDTH-1:0] dout_matrix3;
    wire [DATA_WIDTH-1:0] dout_matrix4;
    wire [DATA_WIDTH-1:0] dout_matrix5;
    wire [DATA_WIDTH-1:0] dout_matrix6;
    wire [DATA_WIDTH-1:0] dout_matrix7;
    wire [DATA_WIDTH-1:0] dout_matrix8;
    wire [DATA_WIDTH-1:0] dout_matrix9;
    wire [DATA_WIDTH-1:0] dout_matrix10;
    wire [DATA_WIDTH-1:0] dout_matrix11;
    wire [DATA_WIDTH-1:0] dout_matrix12;
    wire [DATA_WIDTH-1:0] dout_matrix13;
    wire [DATA_WIDTH-1:0] dout_matrix14;
    wire [DATA_WIDTH-1:0] dout_matrix15;

    // Instantiate mem_dna_axi_lite (Slave 4)
    DNA_MEM_AXI_LITE #(
        .MEM_SIZE(4),      // 500B
        .MEM_SIZE_RR(4),
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) dna_mem (
        .clk(clk),
        .resetn(resetn),
        .i_axi_awvalid(dna_mem_awvalid),
        .o_axi_awready(dna_mem_awready),
        .i_axi_awaddr(s_mem_awaddr),
        .i_axi_wvalid(dna_mem_wvalid),
        .o_axi_wready(dna_mem_wready),
        .i_axi_wdata(dna_mem_wdata),
        .i_axi_wstrb(dna_mem_wstrb),
        .o_axi_bvalid(dna_mem_bvalid),
        .i_axi_bready(dna_mem_bready),
        .i_axi_arvalid(dna_mem_arvalid),
        .o_axi_arready(dna_mem_arready),
        .i_axi_araddr(s_mem_araddr),
        .o_axi_rvalid(dna_mem_rvalid),
        .i_axi_rready(dna_mem_rready),
        .o_axi_rdata(dna_mem_rdata),
        //port mem
        .addr_read(addr_read_o),
        .addr_ref(addr_ref_o),  
        .dout_read(read_32_i),
        .dout_ref(ref_32_i),  
        .we_matrix({16{W_matrix}}),
        .addw_matrix0(addr_matrix_o),
        .addw_matrix1(addr_matrix_o),
        .addw_matrix2(addr_matrix_o),
        .addw_matrix3(addr_matrix_o),
        .addw_matrix4(addr_matrix_o),
        .addw_matrix5(addr_matrix_o),
        .addw_matrix6(addr_matrix_o),
        .addw_matrix7(addr_matrix_o),
        .addw_matrix8(addr_matrix_o),
        .addw_matrix9(addr_matrix_o),
        .addw_matrix10(addr_matrix_o),
        .addw_matrix11(addr_matrix_o),
        .addw_matrix12(addr_matrix_o),
        .addw_matrix13(addr_matrix_o),
        .addw_matrix14(addr_matrix_o),
        .addw_matrix15(addr_matrix_o), 
        .din_matrix0(dout_matrix0),
        .din_matrix1(dout_matrix1),
        .din_matrix2(dout_matrix2),
        .din_matrix3(dout_matrix3),
        .din_matrix4(dout_matrix4),
        .din_matrix5(dout_matrix5),
        .din_matrix6(dout_matrix6),
        .din_matrix7(dout_matrix7),
        .din_matrix8(dout_matrix8),
        .din_matrix9(dout_matrix9),
        .din_matrix10(dout_matrix10),
        .din_matrix11(dout_matrix11),
        .din_matrix12(dout_matrix12),
        .din_matrix13(dout_matrix13),
        .din_matrix14(dout_matrix14),
        .din_matrix15(dout_matrix15)
    );

    // Instantiate ip_dna_axi_lite (Slave 5)
    dna_core_axi_lite #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .addr_start_read(0),
        .addr_start_ref(0),
        .addr_end_ref('d4),
        .addr_start_matrix(0),
        .addr_end_matrix('d4) 
    ) dna_core_axi_lite_unit (
        .clk(clk),
        .resetn(resetn),
        .i_axi_awvalid(dna_ip_awvalid),
        .o_axi_awready(dna_ip_awready),
        .i_axi_awaddr(s_mem_awaddr),
        .i_axi_wvalid(dna_ip_wvalid),
        .o_axi_wready(dna_ip_wready),
        .i_axi_wdata(dna_ip_wdata),
        .i_axi_wstrb(dna_ip_wstrb),
        .o_axi_bvalid(dna_ip_bvalid),
        .i_axi_bready(dna_ip_bready),
        .i_axi_arvalid(dna_ip_arvalid),
        .o_axi_arready(dna_ip_arready),
        .i_axi_araddr(s_mem_araddr),
        .o_axi_rvalid(dna_ip_rvalid),
        .i_axi_rready(dna_ip_rready),
        .o_axi_rdata(dna_ip_rdata),
        .ref_32_i(ref_32_i),
        .read_32_i(read_32_i),
        .W_matrix(W_matrix),
        .addr_ref_o(addr_ref_o),
        .addr_read_o(addr_read_o),
        .addr_matrix_o(addr_matrix_o),
        .dout_matrix0(dout_matrix0),
        .dout_matrix1(dout_matrix1),
        .dout_matrix2(dout_matrix2),
        .dout_matrix3(dout_matrix3),
        .dout_matrix4(dout_matrix4),
        .dout_matrix5(dout_matrix5),
        .dout_matrix6(dout_matrix6),
        .dout_matrix7(dout_matrix7),
        .dout_matrix8(dout_matrix8),
        .dout_matrix9(dout_matrix9),
        .dout_matrix10(dout_matrix10),
        .dout_matrix11(dout_matrix11),
        .dout_matrix12(dout_matrix12),
        .dout_matrix13(dout_matrix13),
        .dout_matrix14(dout_matrix14),
        .dout_matrix15(dout_matrix15)
    );

endmodule