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
  ram.memory[12] = 0xAB
  ram.memory[13] = 0xCD
  ram.memory[14] = 0xEF
  ram.memory[15] = 0x01
  ram.setFormat(0)
  ram.setMar(12)
  ram.read()
  equal(ram.mdr, 0xAB, "should be 0xAB")

test "read memory, 2 byte", ->
  ram.memory[12] = 0xAB
  ram.memory[13] = 0xCD
  ram.memory[14] = 0xEF
  ram.memory[15] = 0x01
  ram.setFormat(1)
  ram.setMar(12)
  ram.read()
  equal(ram.mdr, 0xABCD, "should be 0xABCD")

test "read memory, 3 byte", ->
  ram.memory[12] = 0xAB
  ram.memory[13] = 0xCD
  ram.memory[14] = 0xEF
  ram.memory[15] = 0x01
  ram.setFormat(2)
  ram.setMar(12)
  ram.read()
  equal(ram.mdr, 0xABCDEF, "should be 0xABCDEF")

test "read memory, 4 byte", ->
  ram.memory[12] = 0xAB
  ram.memory[13] = 0xCD
  ram.memory[14] = 0xEF
  ram.memory[15] = 0x01
  ram.setFormat(3)
  ram.setMar(12)
  ram.read()
  equal(ram.mdr, 0xABCDEF01, "should be 0xABCDEF01")