// ============================================================
// Cache Definitions Header (cache_defs.vh)
// ============================================================

// Number of bytes per cache block (1 byte)
`define BLOCK_BYTES      1

// Width of the address bus (e.g., 32‑bit physical address space)
`define ADDR_WIDTH       32

// Offset width = log2(BLOCK_BYTES)
`define OFFSET_WIDTH     0   // log2(1) = 0 bits for a 1‑byte offset

// Number of sets = 128  →  index width = log2(128) = 7
`define INDEX_WIDTH      7   // 128 sets

// Tag width = ADDR_WIDTH − INDEX_WIDTH − OFFSET_WIDTH
`define TAG_WIDTH        (`ADDR_WIDTH - `INDEX_WIDTH - `OFFSET_WIDTH)

// Size of an entire cache block in bits
`define BLOCK_WIDTH      (`BLOCK_BYTES * 8)
