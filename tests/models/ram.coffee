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

test "read memory, 1 byte", ->
  ram.memory[12] = 0x0000ABCD
  ram.memory[13] = 0xEF010000
  ram.setFormat(0)
  ram.setMar(50)
  ram.read()
  equal(ram.mdr, 0xAB, "should be 0xAB")

test "read memory, 2 byte", ->
  ram.memory[12] = 0x0000ABCD
  ram.memory[13] = 0xEF010000
  ram.setFormat(1)
  ram.setMar(50)
  ram.read()
  equal(ram.mdr, 0xABCD, "should be 0xABCD")

test "read memory, 3 byte", ->
  ram.memory[12] = 0x0000ABCD
  ram.memory[13] = 0xEF010000
  ram.setFormat(2)
  ram.setMar(50)
  ram.read()
  equal(ram.mdr, 0xABCDEF, "should be 0xABCDEF")

test "read memory, 4 byte", ->
  ram.memory[12] = 0x0000ABCD
  ram.memory[13] = 0xEF010000
  ram.setFormat(3)
  ram.setMar(50)
  ram.read()
  equal(ram.mdr, 0xABCDEF01, "should be 0xABCDEF01")

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