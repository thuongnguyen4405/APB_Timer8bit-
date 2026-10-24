# Base Test - flow giống bài I2C ICTC

## Ai làm gì?

- **Derived testcase** (`register_rw_test`, `counter_count_up_test`, v.v.): định nghĩa bước kiểm tra trong `run_scenario()`.
- **base_test.sv**: `write()` và `read()` **tạo packet** và gọi `env.stim.send_pkt(pkt)`. `read_expect()` so sánh một APB read với expected của testcase.
- **environment.sv**: tạo Driver/Monitor/Stimulus/Scoreboard, 2 mailbox; `start()`, `reset_dut()`, `expect_bit/expect_mask()`, `check_no_errors()`.
- **stimulus.sv**: queue `pkt_q` -> mailbox `s2d_mb`; `send_pkt()` chờ `@(pkt.done)`.
- **driver.sv**: nhận từ `s2d_mb`, drive APB SETUP/ACCESS; khi hoàn thành đọc `prdata` vào `pkt.rdata`, rồi `->pkt.done`.
- **monitor.sv**: quan sát bus độc lập, gửi packet riêng vào `m2s_mb`.
- **scoreboard.sv**: đọc packet của Monitor, cập nhật expected register khi write, so sánh actual khi read.
- **testbench.sv**: chọn derived testcase bằng `+TESTNAME`.

## Vì sao không copy y chang event xfer_done của I2C?

I2C trong ảnh dùng `@(env.drv.xfer_done)` ở `base_test`. Timer hiện dùng **event trên từng packet** (`pkt.done`) và `stimulus.send_pkt()` **đã chờ done**.
Vì vậy sau `env.stim.send_pkt(pkt)` trong `base_test` **KHÔNG** chờ thêm `@(pkt.done)` hay `@(env.drv.xfer_done)`, tránh treo do lỡ event.

## Đối chiếu câu lệnh

Trước (bản cũ): `env.apb_write(8'h02, 8'hA5);` -> Sau: `write(8'h02, 8'hA5);`
Trước (bản cũ): `env.apb_read(8'h02, data);` -> Sau: `read(8'h02, data);`

## Example đơn giản

```systemverilog
class register_basic_test extends base_test;
    function new(virtual dut_if v);
        super.new(v, "register_basic_test");
    endfunction
    virtual task run_scenario();
        logic [7:0] data;
        write(8'h02, 8'hA5);
        read(8'h02, data);
        env.expect_mask("TDR", data, 8'hA5, 8'hFF);
    endtask
endclass
```

## Lưu ý khi đổi code trên ICTC

Phải đồng bộ `base_test.sv`, `environment.sv` và **cả 24 testcase**. Không chỉ thay `base_test.sv` vì testcase cũ còn gọi `env.apb_write/read`.
Thêm `time issue_time;` vào `packet.sv` vì `monitor.sv` cũ dùng `p.issue_time=$time;`.
**Không thay** Driver, Stimulus, Monitor, Scoreboard, testbench, timer_pkg; không bật Coverage/Assertions.

## Trạng thái kiểm tra

Đã làm static checks (tên class, dependency, số testcase, tất cả `env.apb_write/read` đã chuyển sang `write/read`).
**Chưa chạy Questa / RTL protected**, cần `make build` và chạy `register_reset_test`, `register_rw_test` trên ICTC.
