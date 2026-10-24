// Simple APB register checker. NO coverage and NO plusargs here.
// Monitor -> m2s_mb -> Scoreboard
class scoreboard;
    mailbox #(packet) m2s_mb;

    bit [7:0] tcr_exp = 0;
    bit [7:0] tdr_exp = 0;
    bit [7:0] tie_exp = 0;

    int checks = 0;
    int errors = 0;
    int observations = 0;

    function new(mailbox #(packet) mb);
        m2s_mb = mb;
    endfunction

    function void reset_model();
        tcr_exp = 0;
        tdr_exp = 0;
        tie_exp = 0;
    endfunction

    task run();
        packet pkt;
        forever begin
            m2s_mb.get(pkt);
            observations++;

            if (pkt.op == APB_WRITE) begin
                // Remember writable register fields only.
                case (pkt.addr)
                    8'h00: begin
                        tcr_exp[4:3] = pkt.data[4:3]; // clk_div
                        tcr_exp[1]   = pkt.data[1];   // count_down
                        tcr_exp[0]   = pkt.data[0];   // timer_en
                    end
                    8'h02: tdr_exp = pkt.data;
                    8'h03: tie_exp[1:0] = pkt.data[1:0];
                    default: ; // TSR is hardware-set, software W1C.
                endcase
            end
            else begin
                // Compare DUT readback with values observed from writes.
                case (pkt.addr)
                    8'h00: begin
                        checks++;
                        if (pkt.rdata[4:3] !== tcr_exp[4:3]) begin
                            errors++;
                            $error("[SB] TCR.clk_div got=%b expected=%b",pkt.rdata[4:3],tcr_exp[4:3]);
                        end
                        checks++;
                        if (pkt.rdata[1] !== tcr_exp[1]) begin
                            errors++;
                            $error("[SB] TCR.count_down got=%b expected=%b",pkt.rdata[1],tcr_exp[1]);
                        end
                        checks++;
                        if (pkt.rdata[0] !== tcr_exp[0]) begin
                            errors++;
                            $error("[SB] TCR.timer_en got=%b expected=%b",pkt.rdata[0],tcr_exp[0]);
                        end
                        checks++;
                        if (pkt.rdata[7:5] !== 3'b000) begin
                            errors++;
                            $error("[SB] TCR.reserved got=%b expected=000",pkt.rdata[7:5]);
                        end
                        // TCR.LOAD[2]: handled by scenario, not generic readback.
                    end
                    8'h01: begin
                        checks++;
                        if (pkt.rdata[7:2] !== 6'b000000) begin
                            errors++;
                            $error("[SB] TSR.reserved got=%b expected=0",pkt.rdata[7:2]);
                        end
                        // TSR[1:0] are HW events, checked by directed tests.
                    end
                    8'h02: begin
                        checks++;
                        if (pkt.rdata !== tdr_exp) begin
                            errors++;
                            $error("[SB] TDR got=%02h expected=%02h",pkt.rdata,tdr_exp);
                        end
                    end
                    8'h03: begin
                        checks++;
                        if (pkt.rdata[1:0] !== tie_exp[1:0]) begin
                            errors++;
                            $error("[SB] TIE[1:0] got=%b expected=%b",pkt.rdata[1:0],tie_exp[1:0]);
                        end
                        checks++;
                        if (pkt.rdata[7:2] !== 6'b000000) begin
                            errors++;
                            $error("[SB] TIE.reserved got=%b expected=0",pkt.rdata[7:2]);
                        end
                    end
                    default: begin
                        checks++;
                        if (pkt.rdata !== 8'h00) begin
                            errors++;
                            $error("[SB] Reserved addr=%02h got=%02h expected=00",pkt.addr,pkt.rdata);
                        end
                    end
                endcase
            end
        end
    endtask
endclass
