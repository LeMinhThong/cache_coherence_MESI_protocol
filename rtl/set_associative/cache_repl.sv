module plru_4way (
  input  logic        clk,
  input  logic        rst_n,
  // On a cache access:
  input  logic        access_valid,
  input  logic [1:0]  access_way,    // which way was hit/fill: 0..3
  // On an eviction request:
  input  logic        evict_req,
  output logic [1:0]  evict_way      // victim way: 0..3
);

  // 3‑bit tree state: [2]=root, [1]=left, [0]=right
  logic [2:0] plru_bits;

  // --- Victim selection logic (combinational) ---
  always_comb begin
    if (!evict_req) begin
      evict_way = '0;
    end else begin
      // Start at root
      logic go_right = plru_bits[2];
      // Choose left or right subtree
      if (!go_right) begin
        // left subtree
        evict_way[1] = 1'b0;
        evict_way[0] = (plru_bits[1] == 1'b0) ? 1'b0 : 1'b1;
      end else begin
        // right subtree
        evict_way[1] = 1'b1;
        evict_way[0] = (plru_bits[0] == 1'b0) ? 1'b0 : 1'b1;
      end
    end
  end

  // --- Update logic: on access, flip bits away from accessed way ---
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      // Initialize to “all zeros” → choose way 3 first
      plru_bits <= 3'b000;
    end else if (access_valid) begin
      unique case (access_way)
        2'b00: begin
          // W0 touched → mark path away from 0,0
          plru_bits[2] <= 1'b1;  // point to right subtree
          plru_bits[1] <= 1'b1;  // within left subtree, point to W1
        end
        2'b01: begin
          // W1 touched
          plru_bits[2] <= 1'b1;
          plru_bits[1] <= 1'b0;
        end
        2'b10: begin
          // W2 touched
          plru_bits[2] <= 1'b0;
          plru_bits[0] <= 1'b1;
        end
        2'b11: begin
          // W3 touched
          plru_bits[2] <= 1'b0;
          plru_bits[0] <= 1'b0;
        end
      endcase
    end
    // (no change on evict_req alone)
  end

endmodule
