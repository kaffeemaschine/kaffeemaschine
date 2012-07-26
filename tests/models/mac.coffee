module("MAC")

macListener = new MacListener()
mac = new Mac([macListener])

asyncTest "SetMode notifies listeners", ->

  macListener.setOnSetMode((val) ->
    equal(val, 2, "val should be 2")
    macListener.setOnSetMode(undefined)
    start()
    )

  mac.setMode(2)
  
asyncTest "SetCC notifies listeners", ->

  macListener.setOnSetCC((val) ->
    equal(val, 1, "val should be 1")
    macListener.setOnSetCC(undefined)
    start()
    )

  mac.setCC(1)

asyncTest "SetMask notifies listeners", ->

  macListener.setOnSetMask((val) ->
    equal(val, 2, "val should be 2")
    macListener.setOnSetMask(undefined)
    start()
    )

  mac.setMask(2)

asyncTest "SetTimes4 notifies listeners", ->

  macListener.setOnSetTimes4((val) ->
    equal(val, 1, "val should be 1")
    macListener.setOnSetTimes4(undefined)
    start()
    )

  mac.setTimes4(1)

asyncTest "SetMcop notifies listeners", ->

  macListener.setOnSetMcop((val) ->
    equal(val, 3, "val should be 3")
    macListener.setOnSetMcop(undefined)
    start()
    )

  mac.setMcop(3)

asyncTest "SetMcarNext notifies listeners", ->

  macListener.setOnSetMcarNext((val) ->
    equal(val, 4, "val should be 4")
    macListener.setOnSetMcarNext(undefined)
    start()
    )

  mac.setMcarNext(4)

asyncTest "SetMcn notifies listeners", ->

  macListener.setOnSetMcn((val) ->
    equal(val, 5, "val should be 5")
    macListener.setOnSetMcn(undefined)
    start()
    )

  mac.setMcn(5)

asyncTest "SetMcar notifies listeners", ->

  macListener.setOnSetMcar((val) ->
    equal(val, 6, "val should be 6")
    macListener.setOnSetMcar(undefined)
    start()
    )

  mac.setMcar(6)

test "compute, mode 0", ->
  mac.setMode(0)
  mac.setMcn(2)
  mac.compute()
  equal(mac.mcarNextRegister, 8, "MCARNext should be 8")

test "compute, mode 1", ->
  mac.setMode(1)
  mac.setMcar(2)
  mac.setMcn(3)
  mac.compute()
  equal(mac.mcarNextRegister, 15, "MCARNext should be 15")

test "compute, mode 2", ->
  mac.setMode(2)
  mac.setMcar(20)
  mac.setMcn(3)
  mac.compute()
  equal(mac.mcarNextRegister, 9, "MCARNext should be 9")

test "compute, mode 3, jumpMode 0", ->
  mac.setMode(3)
  mac.setMcop(3)
  mac.setMcn(0)
  mac.compute()
  equal(mac.mcarNextRegister, 12, "MCARNext should be 12")

test "compute, mode 3, jumpMode 1: true", ->
  mac.setMcar(0)
  mac.setMode(3)
  mac.setMcop(3)
  mac.setMcn(16)
  mac.setMask(1)
  mac.setCC(1)
  mac.compute()
  equal(mac.mcarNextRegister, 12, "MCARNext should be 12")

test "compute, mode 3, jumpMode 1: false", ->
  mac.setMcar(0)
  mac.setMode(3)
  mac.setMcop(3)
  mac.setMcn(16)
  mac.setMask(0)
  mac.setCC(1)
  mac.compute()
  equal(mac.mcarNextRegister, 1, "MCARNext should be 1")

test "compute, mode 3, jumpMode 2: true", ->
  mac.setMcar(0)
  mac.setMode(3)
  mac.setMcop(3)
  mac.setMcn(32)
  mac.setMask(0)
  mac.setCC(1)
  mac.compute()
  equal(mac.mcarNextRegister, 12, "MCARNext should be 1")

test "compute, mode 3, jumpMode 2: false", ->
  mac.setMcar(0)
  mac.setMode(3)
  mac.setMcop(3)
  mac.setMcn(32)
  mac.setMask(1)
  mac.setCC(1)
  mac.compute()
  equal(mac.mcarNextRegister, 1, "MCARNext should be 1")

test "compute, mode 3, jumpMode 3", ->
  mac.setMcar(0)
  mac.setMode(3)
  mac.setMcop(3)
  mac.setMcn(48)
  mac.setMask(1)
  mac.setCC(1)
  mac.compute()
  equal(mac.mcarNextRegister, 1, "MCARNext should be 1")