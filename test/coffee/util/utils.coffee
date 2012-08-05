module("Utils")

test "isBitSet", ->
  num = parseInt '101111', 2
  equal( Utils.isBitSet(num, 1), on, "Bit 1 is on" )
  equal( Utils.isBitSet(num, 2), on, "Bit 2 is on" )
  equal( Utils.isBitSet(num, 3), on, "Bit 3 is on" )
  equal( Utils.isBitSet(num, 4), on, "Bit 4 is on" )
  equal( Utils.isBitSet(num, 5), off, "Bit 5 is off" )
  equal( Utils.isBitSet(num, 6), on, "Bit 6 is on" )

test "getHighestBitSet", ->
  num = parseInt '101111', 2
  bit = Utils.getHighestBitSet num, 1, 5
  equal( bit, 4, "Highest bit set is 4" )

test "getLowestBitSet", ->
  num = parseInt '101111', 2
  bit = Utils.getLowestBitSet num, 1, 5
  equal( bit, 1, "Lowest bit set is 1" )

test "setBit", ->
  tmp = 0
  tmp = Utils.setBit(tmp, 1)
  tmp = Utils.setBit(tmp, 2)
  tmp = Utils.setBit(tmp, 3)
  tmp = Utils.setBit(tmp, 4)
  tmp = Utils.setBit(tmp, 6)
  equal( tmp, 0x2F, "Should be equal" )

test "unsetBit", ->
  tmp = 0x2F
  tmp = Utils.unsetBit(tmp, 1)
  tmp = Utils.unsetBit(tmp, 2)
  tmp = Utils.unsetBit(tmp, 3)
  tmp = Utils.unsetBit(tmp, 4)
  tmp = Utils.unsetBit(tmp, 6)
  equal( tmp, 0, "Should be equal" )

test "toggleBit when off", ->
  tmp = 0
  tmp = Utils.toggleBit(tmp, 1)
  equal( tmp, 1, "Should be equal" )

test "toggleBit when on", ->
  tmp = 1
  tmp = Utils.toggleBit(tmp, 1)
  equal( tmp, 0, "Should be equal" )

test "isNegative true", ->
  equal( Utils.isNegative(0x8FFFFFFF), true, "Should be true")

test "isNegative false", ->
  equal( Utils.isNegative(0x7FFFFFFF), false, "Should be false")

test "extractNum", ->
  num = parseInt '101101', 2
  equal( Utils.extractNum(num, 2, 4), 6, "Extracted num should be 6" )

test "randomBitSequence", ->
  num = Utils.randomBitSequence(32)
  ok(num.toString(2).length <= 32)
