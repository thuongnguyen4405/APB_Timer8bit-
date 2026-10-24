class stimulus;
    packet pkt_q[$];
    mailbox #(packet) s2d_mb;

    function new(mailbox #(packet) mb);
        s2d_mb = mb;
    endfunction

    // The testcase sends one request and waits for Driver to finish.
    task send_pkt(packet pkt);
        pkt_q.push_back(pkt);
        @(pkt.done);
    endtask

    // Separate process forwards queued requests to Driver's mailbox.
    task run();
        packet pkt;
        forever begin
            wait (pkt_q.size() > 0);
            pkt = pkt_q.pop_front();
            s2d_mb.put(pkt);
        end
    endtask
endclass
