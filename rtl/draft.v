  // ----------------------------------------------------------------
  // TAG RAM & DATA RAM register definition
  // ----------------------------------------------------------------
  // way 0
  reg                 valid_0 [0:(NUM_CACHE_LINE/4)-1];
  reg                 dirty_0 [0:(NUM_CACHE_LINE/4)-1];
  reg [TAG_WIDTH-1:0] tag_0   [0:(NUM_CACHE_LINE/4)-1];
  reg [LINE_SIZE-1:0] mem_0   [0:(NUM_CACHE_LINE/4)-1];

  // way 1
  reg                 valid_1 [0:(NUM_CACHE_LINE/4)-1];
  reg                 dirty_1 [0:(NUM_CACHE_LINE/4)-1];
  reg [TAG_WIDTH-1:0] tag_1   [0:(NUM_CACHE_LINE/4)-1];
  reg [LINE_SIZE-1:0] mem_1   [0:(NUM_CACHE_LINE/4)-1];

  // way 2
  reg                 valid_2 [0:(NUM_CACHE_LINE/4)-1];
  reg                 dirty_2 [0:(NUM_CACHE_LINE/4)-1];
  reg [TAG_WIDTH-1:0] tag_2   [0:(NUM_CACHE_LINE/4)-1];
  reg [LINE_SIZE-1:0] mem_2   [0:(NUM_CACHE_LINE/4)-1];

  // way 3
  reg                 valid_3 [0:(NUM_CACHE_LINE/4)-1];
  reg                 dirty_3 [0:(NUM_CACHE_LINE/4)-1];
  reg [TAG_WIDTH-1:0] tag_3   [0:(NUM_CACHE_LINE/4)-1];
  reg [LINE_SIZE-1:0] mem_3   [0:(NUM_CACHE_LINE/4)-1];

