# Hướng dẫn học Project 1 – 8-bit Timer (ICTC)

## 1. Hiểu đúng cấu trúc, không cần UVM

Tập trung vào luồng dữ liệu. Mỗi component chỉ có một nhiệm vụ:

| File | Nhiệm vụ | Một dòng cần nhớ |
|---|---|---|
| `tb/packet.sv` | Lưu yêu cầu APB (addr, data, op), dữ liệu đọc (`rdata`) và event (`done`) | `event done;` |
| `tb/stimulus.sv` | Nhận packet vào queue, đưa sang mailbox Driver | `s2d_mb.put(pkt);` |
| `tb/driver.sv` | Điều khiển tín hiệu APB trên interface | `vif.penable = 1;` |
| `tb/monitor.sv` | **Quan sát DUT** và gửi transaction thực sự đã hoàn tất | `m2s_mb.put(p);` |
| `tb/scoreboard.sv` | So sánh readback APB với register model đơn giản | `if (pkt.rdata !== tdr_exp)` |
| `tb/environment.sv` | Ghép tất cả component, cung cấp `apb_write` / `apb_read` | `fork ... join_none` |
| `testcase/base_test.sv` | Reset, gọi scenario, quyết định PASS/FAIL | `run_scenario();` |
| `testcase/*_test.sv` | Mô tả kiểm tra từng mục Vplan | `virtual task run_scenario();` |
| `tb/testbench.sv` | Đọc **duy nhất** `+TESTNAME` và khởi tạo derived test | `$value$plusargs` |

## 2. Ví dụ ghi và đọc TDR

Testcase gọi `env.apb_write(8'h02, 8'hA5)`:

1. `environment.apb_write()` tạo `packet` có `addr=02`, `data=A5`, `op=APB_WRITE`.
2. `stimulus.send_pkt()` push packet vào queue và chờ `@(pkt.done)`.
3. `stimulus.run()` lấy packet từ queue, gửi `s2d_mb`.
4. `driver.run()` lấy packet, tạo **SETUP** (`PSEL=1,PENABLE=0`), sau đó **ACCESS** (`PSEL=1,PENABLE=1`).
5. APB hoàn thành khi `PREADY=1`; Driver về IDLE rồi `->pkt.done`.
6. `monitor.run()` **tự quan sát tín hiệu interface**, tạo packet *khác* và gửi `m2s_mb`.
7. `scoreboard.run()` nhận observed packet; đây là write nên ghi nhớ `tdr_exp=A5`.
8. Khi testcase đọc địa chỉ 02, Monitor lấy `PRDATA`; Scoreboard so `PRDATA` với `tdr_exp`.

**Vì sao cần Monitor?** Không được lấy trực tiếp giá trị mà testcase muốn gửi rồi gọi đó là DUT observed data; phải quan sát giao dịch thật trên bus.

## 3. Vì sao Scoreboard không model tất cả?

- TCR `clk_div[4:3]`, `count_down[1]`, `timer_en[0]`: lưu shadow và kiểm tra từng bit/field.
- TDR `[7:0]`: ghi gì, đọc lại kỳ vọng tương ứng.
- TIE `[1:0]`: lưu và kiểm tra từng field cùng reserved bits.
- TSR `[1:0]`: **không** phải R/W bình thường: hardware tự set, APB write-one-to-clear. Cần testcase tạo overflow/underflow rồi poll để kiểm tra.
- TCR.LOAD `[2]`: slide ghi R/W, nhưng chưa mô tả rõ self-clear và readback khi tác động; để testcase kiểm tra hành vi load riêng.
- Giá trị counter nội bộ: không có top-level port quan sát theo tài liệu nên không được giả vờ Scoreboard biết exact value.

## 4. Khi nào dùng `[n]`, `[m:n]`, `&`?

- `pkt.data[4:3]`: dễ hiểu nhất khi lấy **một field cố định** (`clk_div`).
- `pkt.rdata[0]`: dễ hiểu nhất khi kiểm tra riêng `overflow`.
- `(got & mask) !== (expected & mask)`: vẫn hữu ích cho checker testcase `env.expect_mask`, khi ta chỉ quan tâm một tập bit. AND rất nhanh, không cần lo tối ưu CPU cho một IP 8-bit.

## 5. Cách debug một testcase FAIL

Ví dụ lỗi `[SB] TDR got=5A expected=A5`:

1. Xem testcase có ghi đúng `PADDR=02, PWDATA=A5` chưa.
2. Mở waveform lúc **SETUP -> ACCESS**: `PSEL,PENABLE,PWRITE,PADDR,PWDATA,PREADY`.
3. Xem Monitor nhận đúng WRITE A5 và READ 5A không.
4. Kiểm tra `PRDATA` và thời điểm sample `posedge PCLK + 1ps`.
5. Xem giá trị expected trong Scoreboard có bị reset/update nhầm không.
6. Khi chắc timing và reference đúng, mới nghi ngờ RTL.

**Không kết luận RTL sai chỉ vì `$error` trong Scoreboard.**

## 6. Học và chạy theo thứ tự

1. `register_reset_test` – kiểm tra APB đọc + reset cơ bản.
2. `register_rw_test` – kiểm tra ghi/đọc register.
3. `reserved_fields_address_test` – address decoding.
4. `tsr_w1c_test` – hardware event + W1C.
5. 4 testcase `clock_div*` – quan sát khoảng thời gian wrap (ước lượng).
6. Các testcase Counter, Interrupt – status polling và IRQ.
7. 3 random testcase với nhiều seed – tái hiện bằng `-sv_seed`.
8. **Sau cùng mới thêm covergroup vào Scoreboard** theo `COVERAGE_LATER.md`.

## 7. Giải thích polymorphism trong phỏng vấn

- `base_test` có `virtual task run_scenario()`.
- Các testcase như `register_rw_test extends base_test` override hàm này.
- `testbench.sv` tạo derived object và gán vào biến `base_test t`.
- Gọi `t.run_test()` -> `run_scenario()` của derived class đang được chọn.
- Do đó **compile một lần, chạy nhiều testcase qua `+TESTNAME`**, không sửa logic Scoreboard giữa các testcase.

## 8. Giới hạn thật sự

Questa/RTL `.vp` chỉ có trên server ICTC của bro. Bộ ZIP này **đã qua static check**, không có quyền tuyên bố PASS simulation thật. Nếu timing PRDATA, LOAD, CDC hoặc IRQ thực tế khác assumption, sửa theo waveform và specification/DUT owner chứ không tăng timeout vô căn cứ.
