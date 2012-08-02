module("RAM")

ramListener = new RamListener()
ram = new Ram([ramListener])  

asyncTest "SetMode notifies listeners", ->

  ramListener.setOnSetMode((m) ->
    equal(m, 2, "mode should be 2")
    ramListener.setOnSetMode(undefined)
    start()
    )

  ram.setMode(2)

asyncTest "SetFormat notifies listeners", ->

  ramListener.setOnSetFormat((m) ->
    equal(m, 3, "format should be 3")
    ramListener.setOnSetFormat(undefined)
    start()
    )

  ram.setFormat(3)

asyncTest "SetMdr notifies listeners", ->

  ramListener.setOnSetMdr((m) ->
    equal(m, 4, "mdr should be 4")
    ramListener.setOnSetMdr(undefined)
    start()
    )

  ram.setMdr(4)

asyncTest "SetMar notifies listeners", ->

  ramListener.setOnSetMar((m) ->
    equal(m, 5, "mar should be 5")
    ramListener.setOnSetMar(undefined)
    start()
    )

  ram.setMar(5)

asyncTest "SetByte notifies listeners", ->

  ramListener.setOnSetByte((at, val) ->
    equal(at, 5, "at should be 5")
    equal(val, 6, "val should be 6")
    ramListener.setOnSetByte(undefined)
    start()
    )

  ram.setByte(5,6)

test "read memory, 1 byte", ->
  ram.memory[12] = 0x0000ABCD
  ram.memory[13] = 0xEF010000
  ram.setFormat(0)
  ram.setMar(50)
  ram.read()
  equal(ram.mdr, 0xAB, "should be 0xAB")

test "write memory, 1 byte", ->
  ram.memory[12] = 0x0
  ram.memory[13] = 0x0
  ram.setFormat(0)
  ram.setMdr(0xAB)
  ram.setMar(50)
  ram.write()
  equal(ram.memory[12], 0x0000AB00, "should be 0x0000AB00")

test "read memory, 2 byte", ->
  ram.memory[12] = 0x0000ABCD
  ram.memory[13] = 0xEF010000
  ram.setFormat(1)
  ram.setMar(50)
  ram.read()
  equal(ram.mdr, 0xABCD, "should be 0xABCD")

test "write memory, 2 byte", ->
  ram.memory[12] = 0x0
  ram.memory[13] = 0x0
  ram.setFormat(1)
  ram.setMdr(0xABCD)
  ram.setMar(50)
  ram.write()
  equal(ram.memory[12], 0x0000ABCD, "should be 0x0000ABCD")

test "read memory, 3 byte", ->
  ram.memory[12] = 0x0000ABCD
  ram.memory[13] = 0xEF010000
  ram.setFormat(2)
  ram.setMar(50)
  ram.read()
  equal(ram.mdr, 0xABCDEF, "should be 0xABCDEF")

test "write memory, 3 byte", ->
  ram.memory[12] = 0x0
  ram.memory[13] = 0x0
  ram.setFormat(2)
  ram.setMdr(0xABCDEF)
  ram.setMar(50)
  ram.write()
  equal(ram.memory[12], 0x0000ABCD, "should be 0x0000ABCD")
  equal(ram.memory[13], 0xEF000000, "should be 0xEF000000")

test "read memory, 4 byte", ->
  ram.memory[12] = 0x0000ABCD
  ram.memory[13] = 0xEF010000
  ram.setFormat(3)
  ram.setMar(50)
  ram.read()
  equal(ram.mdr, 0xABCDEF01, "should be 0xABCDEF01")

test "write memory, 4 byte", ->
  ram.memory[12] = 0x0
  ram.memory[13] = 0x0
  ram.setFormat(3)
  ram.setMdr(0xABCDEF01)
  ram.setMar(50)
  ram.write()
  equal(ram.memory[12], 0x0000ABCD, "should be 0x0000ABCD")
  equal(ram.memory[13], 0xEF010000, "should be 0xEF010000")

test "getByte", ->
  ram.memory[0] = 0xABCDEF01
  ram.memory[1] = 0x23456789
  equal(ram.getByte(0), 0xAB, "should be 0xAB")
  equal(ram.getByte(1), 0xCD, "should be 0xCD")
  equal(ram.getByte(2), 0xEF, "should be 0xEF")
  equal(ram.getByte(3), 0x01, "should be 0x01")
  equal(ram.getByte(4), 0x23, "should be 0x23")
  equal(ram.getByte(5), 0x45, "should be 0x45")
  equal(ram.getByte(6), 0x67, "should be 0x67")
  equal(ram.getByte(7), 0x89, "should be 0x89")

test "setByte", ->
  ram.memory[0] = 0
  ram.memory[1] = 0

  ram.setByte(0, 0xAB)
  ram.setByte(1, 0xCD)
  ram.setByte(2, 0xEF)
  ram.setByte(3, 0x01)
  ram.setByte(4, 0x23)
  ram.setByte(5, 0x45)
  ram.setByte(6, 0x67)
  ram.setByte(7, 0x89)
  
  equal(ram.memory[0], 0xABCDEF01, "should be 0xABCDEF01")
  equal(ram.memory[1], 0x23456789, "should be 0x23456789")