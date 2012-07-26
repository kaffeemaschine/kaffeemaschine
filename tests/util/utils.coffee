module("Utils")

test "isBitSet", ->
  num = parseInt '101111', 2
  equal( Utils.isBitSet(num, 1), on, "Bit 1 is on" );
  equal( Utils.isBitSet(num, 2), on, "Bit 2 is on" );
  equal( Utils.isBitSet(num, 3), on, "Bit 3 is on" );
  equal( Utils.isBitSet(num, 4), on, "Bit 4 is on" );
  equal( Utils.isBitSet(num, 5), off, "Bit 5 is off" );
  equal( Utils.isBitSet(num, 6), on, "Bit 6 is on" );

test "getHighestBitSet", ->
  num = parseInt '101111', 2
  bit = Utils.getHighestBitSet num, 1, 5
  equal( bit, 4, "Highest bit set is 4" );
  
test "setBit", ->
  tmp = 0
  tmp = Utils.setBit(tmp, 1)
  tmp = Utils.setBit(tmp, 2)
  tmp = Utils.setBit(tmp, 3)
  tmp = Utils.setBit(tmp, 4)
  tmp = Utils.setBit(tmp, 6)
  equal( tmp, (parseInt '101111', 2), "Should be equal" );
  
test "extractNum", ->
  num = parseInt '101101', 2
  equal( Utils.extractNum(num, 2, 4), 6, "Extracted num should be 6" );