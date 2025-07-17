// ================================================================
// lru_4way.v  ▪  4-way TRUE-LRU (post-update victim, v2001-clean)
// ---------------------------------------------------------------
// • age[set][way] : 2-bit rank  (0 = MRU … 3 = LRU)
// • update_en     : 1-cycle pulse when cache hits / refills
// • victim_way    : chosen **after** the age table is updated
//   (accessed line can never be evicted next)
// ================================================================
`include "cache_defs.vh"

module lru_4way (
  input  wire                         clk,
  input  wire                         reset,

  // update
  input  wire                         update_en,
  input  wire [`INDEX_WIDTH-1:0]      set_idx,
  input  wire [1:0]                   accessed_way,

  // query
  input  wire [`INDEX_WIDTH-1:0]      query_idx,
  output reg  [1:0]                   victim_way
);

  // --------------------------------------------------------------
  // storage: 2-bit age counters
  // --------------------------------------------------------------
  reg [1:0] age [0:(1<<`INDEX_WIDTH)-1][0:3];

  // temp vars (declared at module scope – v2001 rule)
  integer   s, w;
  reg [1:0] old_age, max_age, tmp_victim;

  // --------------------------------------------------------------
  // sequential logic: update + victim pick in same clock edge
  // --------------------------------------------------------------
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      // deterministic reset: way0 MRU … way3 LRU
      for (s = 0; s < (1<<`INDEX_WIDTH); s = s + 1)
        for (w = 0; w < 4; w = w + 1)
          age[s][w] <= w[1:0];
      victim_way <= 2'd0;
    end else begin
      // ---------- 1) strict LRU update (blocking '=') ----------
      if (update_en) begin
        old_age = age[set_idx][accessed_way];
        for (w = 0; w < 4; w = w + 1) begin
          if (w == accessed_way)
            age[set_idx][w] = 2'd0;               // now MRU
          else if (age[set_idx][w] < old_age)
            age[set_idx][w] = age[set_idx][w] + 2'd1;
          // ages >= old_age stay unchanged
        end
      end

      // ---------- 2) victim after the update -------------------
      max_age    = 2'd0;
      tmp_victim = 2'd0;
      for (w = 0; w < 4; w = w + 1) begin
        if (age[query_idx][w] >= max_age) begin
          max_age    = age[query_idx][w];
          tmp_victim = w[1:0];
        end
      end
      victim_way <= tmp_victim;     // registered output
    end
  end

endmodule
