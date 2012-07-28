module("ALU")

aluListener = new AluListener()
alu = new Alu([aluListener])

asyncTest "SetXRegister notifies listeners", ->

  aluListener.setOnSetX((val) ->
    equal(val, 1, "val should be 1")
    aluListener.setOnSetX(undefined)
    start()
    )

  alu.setXRegister(1)

asyncTest "SetYRegister notifies listeners", ->

  aluListener.setOnSetY((val) ->
    equal(val, 2, "val should be 2")
    aluListener.setOnSetY(undefined)
    start()
    )

  alu.setYRegister(2)

asyncTest "SetZRegister notifies listeners", ->

  aluListener.setOnSetZ((val) ->
    equal(val, 3, "val should be 3")
    aluListener.setOnSetZ(undefined)
    start()
    )

  alu.setZRegister(3)

asyncTest "SetCCRegister notifies listeners", ->

  aluListener.setOnSetCC((val) ->
    equal(val, 4, "val should be 4")
    aluListener.setOnSetCC(undefined)
    start()
    )

  alu.setCCRegister(4)

asyncTest "SetFunctionCode notifies listeners", ->

  aluListener.setOnSetFC((val) ->
    equal(val, 5, "val should be 5")
    aluListener.setOnSetFC(undefined)
    start()
    )

  alu.setFunctionCode(5)

asyncTest "SetCCFlags notifies listeners", ->

  aluListener.setOnSetFlags((val) ->
    equal(val, 6, "val should be 6")
    aluListener.setOnSetFlags(undefined)
    start()
    )

  alu.setCCFlags(6)


test "FunctionCode 0: NOP", ->
  alu.setFunctionCode 0
  oldState = alu.getState()
  alu.compute()
  resultState = alu.getState()

  equal( resultState.x, oldState.x, "No change in X Register" )
  equal( resultState.y, oldState.y, "No change in Y Register" )
  equal( resultState.z, oldState.z, "No change in Z Register" )
  equal( resultState.cc, oldState.cc, "No change in CC Register" )
  equal( resultState.ccFlags, oldState.ccFlags, "No change in CC Flags" )

test "FunctionCode 1: -Z->Z when Z > 0", ->
  alu.setFunctionCode 1
  alu.setZRegister 42
  oldState = alu.getState()
  alu.compute()
  resultState = alu.getState()

  equal( resultState.x, oldState.x, "No change in X Register" )
  equal( resultState.y, oldState.y, "No change in Y Register" )
  equal( resultState.z, 0xFFFFFFD6, "Changed to -42 in twos complement" )
  equal( resultState.cc, oldState.cc, "No change in CC Register" )
  equal( resultState.ccFlags, 0x2, "Indicates negative" )

test "FunctionCode 1: -Z->Z when Z < 0", ->
  alu.setFunctionCode 1
  alu.setZRegister 0xFFFFFFD6 # -42
  oldState = alu.getState()
  alu.compute()
  resultState = alu.getState()

  equal( resultState.x, oldState.x, "No change in X Register" )
  equal( resultState.y, oldState.y, "No change in Y Register" )
  equal( resultState.z, 42, "Changed to 42 Register in twos complement" )
  equal( resultState.cc, oldState.cc, "No change in CC Register" )
  equal( resultState.ccFlags, 0x4, "Indicates positive" )

test "FunctionCode 1: -Z->Z when Z = 0", ->
  alu.setFunctionCode 1
  alu.setZRegister 0
  oldState = alu.getState()
  alu.compute()
  resultState = alu.getState()

  equal( resultState.x, oldState.x, "No change in X Register" )
  equal( resultState.y, oldState.y, "No change in Y Register" )
  equal( resultState.z, oldState.z, "No change in Y Register" )
  equal( resultState.cc, oldState.cc, "No change in CC Register" )
  equal( resultState.ccFlags, 0x8, "Indicates zero" )


test "FunctionCode 2: X->Z", ->
  alu.setFunctionCode 2
  alu.setXRegister 1337
  oldState = alu.getState()
  alu.compute()
  resultState = alu.getState()

  equal( resultState.x, oldState.x, "No change in X Register" )
  equal( resultState.y, oldState.y, "No change in Y Register" )
  equal( resultState.z, oldState.x, "Changed to X Register" )
  equal( resultState.cc, oldState.cc, "No change in CC Register" )
  equal( resultState.ccFlags, 0x4, "Indicates positive" )

test "FunctionCode 3: -X->Z when X > 0", ->
  alu.setFunctionCode 3
  alu.setXRegister 42
  oldState = alu.getState()
  alu.compute()
  resultState = alu.getState()

  equal( resultState.x, oldState.x, "No change in X Register" )
  equal( resultState.y, oldState.y, "No change in Y Register" )
  equal( resultState.z, 0xFFFFFFD6, "Changed to -42 in twos complement" )
  equal( resultState.cc, oldState.cc, "No change in CC Register" )
  equal( resultState.ccFlags, 0x2, "Indicates negative" )

test "FunctionCode 3: -X->Z when X < 0", ->
  alu.setFunctionCode 3
  alu.setXRegister 0xFFFFFFD6 # -42
  oldState = alu.getState()
  alu.compute()
  resultState = alu.getState()

  equal( resultState.x, oldState.x, "No change in X Register" )
  equal( resultState.y, oldState.y, "No change in Y Register" )
  equal( resultState.z, 42, "Changed to 42 in twos complement" )
  equal( resultState.cc, oldState.cc, "No change in CC Register" )
  equal( resultState.ccFlags, 0x4, "Indicates positive" )

test "FunctionCode 3: -X->Z when X = 0", ->
  alu.setFunctionCode 3
  alu.setXRegister 0
  oldState = alu.getState()
  alu.compute()
  resultState = alu.getState()

  equal( resultState.x, oldState.x, "No change in X Register" )
  equal( resultState.y, oldState.y, "No change in Y Register" )
  equal( resultState.z, 0, "No change in Z Register" )
  equal( resultState.cc, oldState.cc, "No change in CC Register" )
  equal( resultState.ccFlags, 0x8, "Indicates zero" )

test "FunctionCode 4: Y->Z", ->
  alu.setFunctionCode 4
  alu.setYRegister 1337
  oldState = alu.getState()
  alu.compute()
  resultState = alu.getState()

  equal( resultState.x, oldState.x, "No change in X Register" )
  equal( resultState.y, oldState.y, "No change in Y Register" )
  equal( resultState.z, oldState.y, "Changed to Y Register" )
  equal( resultState.cc, oldState.cc, "No change in CC Register" )
  equal( resultState.ccFlags, 0x4, "Indicates positive" )

test "FunctionCode 5: -Y->Z when Y > 0", ->
  alu.setFunctionCode 5
  alu.setYRegister 42
  oldState = alu.getState()
  alu.compute()
  resultState = alu.getState()

  equal( resultState.x, oldState.x, "No change in X Register" )
  equal( resultState.y, oldState.y, "No change in Y Register" )
  equal( resultState.z, 0xFFFFFFD6, "Changed to -42 in twos complement" )
  equal( resultState.cc, oldState.cc, "No change in CC Register" )
  equal( resultState.ccFlags, 0x2, "Indicates negative" )

test "FunctionCode 5: -Y->Z when Y < 0", ->
  alu.setFunctionCode 5
  alu.setYRegister 0xFFFFFFD6 # -42
  oldState = alu.getState()
  alu.compute()
  resultState = alu.getState()

  equal( resultState.x, oldState.x, "No change in X Register" )
  equal( resultState.y, oldState.y, "No change in Y Register" )
  equal( resultState.z, 42, "Changed to 42 in twos complement" )
  equal( resultState.cc, oldState.cc, "No change in CC Register" )
  equal( resultState.ccFlags, 0x4, "Indicates positive" )

test "FunctionCode 5: -Y->Z when Y = 0", ->
  alu.setFunctionCode 5
  alu.setYRegister 0
  oldState = alu.getState()
  alu.compute()
  resultState = alu.getState()

  equal( resultState.x, oldState.x, "No change in X Register" )
  equal( resultState.y, oldState.y, "No change in Y Register" )
  equal( resultState.z, 0, "No change in Z Register" )
  equal( resultState.cc, oldState.cc, "No change in CC Register" )
  equal( resultState.ccFlags, 0x8, "Indicates zero" )

test "FunctionCode 6: Y->Z, X<->Y", ->
  alu.setFunctionCode 6
  alu.setXRegister 1
  alu.setYRegister 2
  oldState = alu.getState()
  alu.compute()
  resultState = alu.getState()

  equal( resultState.x, oldState.y, "Swapped with Y Register" )
  equal( resultState.y, oldState.x, "Swapped with X Register" )
  equal( resultState.z, oldState.y, "Original Y value" )
  equal( resultState.cc, oldState.cc, "No change in CC Register" )
  equal( resultState.ccFlags, 0x04, "Indicates positive" )

test "FunctionCode 7: X->Z, X<->Y", ->
  alu.setFunctionCode 7
  alu.setXRegister 1
  alu.setYRegister 2
  oldState = alu.getState()
  alu.compute()
  resultState = alu.getState()

  equal( resultState.x, oldState.y, "Swapped with Y Register" )
  equal( resultState.y, oldState.x, "Swapped with X Register" )
  equal( resultState.z, oldState.x, "Original X value" )
  equal( resultState.cc, oldState.cc, "No change in CC Register" )
  equal( resultState.ccFlags, 0x04, "Indicates positive" )


test "FunctionCode 8: Y->Z, Y->X", ->
  alu.setFunctionCode 8
  alu.setXRegister 1
  alu.setYRegister 2
  oldState = alu.getState()
  alu.compute()
  resultState = alu.getState()

  equal( resultState.x, oldState.y, "Changed to Y Register" )
  equal( resultState.y, oldState.y, "No change in Y Register" )
  equal( resultState.z, oldState.y, "Changed to Y Register" )
  equal( resultState.cc, oldState.cc, "No change in CC Register" )
  equal( resultState.ccFlags, 0x04, "Indicates positive" )

test "FunctionCode 9: X+1->Z when X >= 0", ->
  alu.setFunctionCode 9
  alu.setXRegister 1336
  oldState = alu.getState()
  alu.compute()
  resultState = alu.getState()

  equal( resultState.x, oldState.x, "No change in X Register" )
  equal( resultState.y, oldState.y, "No change in Y Register" )
  equal( resultState.z, oldState.x+1, "Changed to X Register + 1" )
  equal( resultState.cc, oldState.cc, "No change in CC Register" )
  equal( resultState.ccFlags, 0x4, "Indicates positive" )

test "FunctionCode 9: X+1->Z when X < 0", ->
  alu.setFunctionCode 9
  alu.setXRegister 0xFFFFFFD6 # -42
  oldState = alu.getState()
  alu.compute()
  resultState = alu.getState()

  equal( resultState.x, oldState.x, "No change in X Register" )
  equal( resultState.y, oldState.y, "No change in Y Register" )
  equal( resultState.z, 0xFFFFFFD7, "Changed to -41 in twos complement" )
  equal( resultState.cc, oldState.cc, "No change in CC Register" )
  equal( resultState.ccFlags, 0x2, "Indicates negative" )

test "FunctionCode 9: X+1->Z when overflow", ->
  alu.setFunctionCode 9
  alu.setXRegister 0x7FFFFFFF
  oldState = alu.getState()
  alu.compute()
  resultState = alu.getState()

  equal( resultState.x, oldState.x, "No change in X Register" )
  equal( resultState.y, oldState.y, "No change in Y Register" )
  equal( resultState.z, 0x80000000, "Changed to least possible value (overflow)" )
  equal( resultState.cc, oldState.cc, "No change in CC Register" )
  equal( resultState.ccFlags, 0x5, "Indicates positive + overflow" )

test "FunctionCode 10: X-1->Z when X > 0", ->
  alu.setFunctionCode 10
  alu.setXRegister 1338
  oldState = alu.getState()
  alu.compute()
  resultState = alu.getState()

  equal( resultState.x, oldState.x, "No change in X Register" )
  equal( resultState.y, oldState.y, "No change in Y Register" )
  equal( resultState.z, oldState.x-1, "Changed to Y Register - 1" )
  equal( resultState.cc, oldState.cc, "No change in CC Register" )
  equal( resultState.ccFlags, 0x4, "Indicates positive" )

test "FunctionCode 10: X-1->Z when X <= 0", ->
  alu.setFunctionCode 10
  alu.setXRegister 0xFFFFFFD6 # -42
  oldState = alu.getState()
  alu.compute()
  resultState = alu.getState()

  equal( resultState.x, oldState.x, "No change in X Register" )
  equal( resultState.y, oldState.y, "No change in Y Register" )
  equal( resultState.z, 0xFFFFFFD5, "Changed to -43 in twos complement" )
  equal( resultState.cc, oldState.cc, "No change in CC Register" )
  equal( resultState.ccFlags, 0x2, "Indicates negative" )

test "FunctionCode 10: X-1->Z, underflow", ->
  alu.setFunctionCode 10
  alu.setXRegister 0x80000000
  oldState = alu.getState()
  alu.compute()
  resultState = alu.getState()
  equal( resultState.x, oldState.x, "No change in X Register" )
  equal( resultState.y, oldState.y, "No change in Y Register" )
  equal( resultState.z, 0x7FFFFFFF, "Changed to max (underflow)" )
  equal( resultState.cc, oldState.cc, "No change in CC Register" )
  equal( resultState.ccFlags, 0x3, "Indicates negative + overflow" )

test "FunctionCode 11: X+Y->Z", ->
  alu.setFunctionCode 11
  alu.setXRegister 47
  alu.setYRegister 11
  oldState = alu.getState()
  alu.compute()
  resultState = alu.getState()
  equal( resultState.x, oldState.x, "No change in X Register" )
  equal( resultState.y, oldState.y, "No change in Y Register" )
  equal( resultState.z, oldState.x + oldState.y, "Changed to X+Y" )
  equal( resultState.cc, oldState.cc, "No change in CC Register" )
  equal( resultState.ccFlags, 0x4, "Indicates positive" )

test "FunctionCode 11: X+Y->Z, overflow", ->
  alu.setFunctionCode 11
  alu.setXRegister 1
  alu.setYRegister 0x7FFFFFFF
  oldState = alu.getState()
  alu.compute()
  resultState = alu.getState()
  equal( resultState.x, oldState.x, "No change in X Register" )
  equal( resultState.y, oldState.y, "No change in Y Register" )
  equal( resultState.z, 0x80000000, "Changed to least possible value (overflow)")
  equal( resultState.cc, oldState.cc, "No change in CC Register" )
  equal( resultState.ccFlags, 0x5, "Indicates positive + overflow" )

test "FunctionCode 11: X+Y->Z, underflow", ->
  alu.setFunctionCode 11
  alu.setXRegister 0x80000000
  alu.setYRegister 0xFFFFFFFF
  oldState = alu.getState()
  alu.compute()
  resultState = alu.getState()
  equal( resultState.x, oldState.x, "No change in X Register" )
  equal( resultState.y, oldState.y, "No change in Y Register" )
  equal( resultState.z, 0x7FFFFFFF, "Changed to highest possible value (underflow)")
  equal( resultState.cc, oldState.cc, "No change in CC Register" )
  equal( resultState.ccFlags, 0x3, "Indicates negative + overflow" )

test "FunctionCode 12: X-Y->Z", ->
  alu.setFunctionCode 12
  alu.setXRegister 47
  alu.setYRegister 11
  oldState = alu.getState()
  alu.compute()
  resultState = alu.getState()
  equal( resultState.x, oldState.x, "No change in X Register" )
  equal( resultState.y, oldState.y, "No change in Y Register" )
  equal( resultState.z, oldState.x - oldState.y, "Changed to X-Y" )
  equal( resultState.cc, oldState.cc, "No change in CC Register" )
  equal( resultState.ccFlags, 0x4, "Indicates positive" )

test "FunctionCode 12: X-Y->Z, overflow", ->
  alu.setFunctionCode 12
  alu.setXRegister 0
  alu.setYRegister 0x80000000
  oldState = alu.getState()
  alu.compute()
  resultState = alu.getState()
  equal( resultState.x, oldState.x, "No change in X Register" )
  equal( resultState.y, oldState.y, "No change in Y Register" )
  equal( resultState.z, 0x80000000, "Changed to least possible value (overflow)")
  equal( resultState.cc, oldState.cc, "No change in CC Register" )
  equal( resultState.ccFlags, 0x5, "Indicates positive + overflow" )

test "FunctionCode 12: X-Y->Z, underflow", ->
  alu.setFunctionCode 12
  alu.setXRegister 0x80000000
  alu.setYRegister 0x1
  oldState = alu.getState()
  alu.compute()
  resultState = alu.getState()
  equal( resultState.x, oldState.x, "No change in X Register" )
  equal( resultState.y, oldState.y, "No change in Y Register" )
  equal( resultState.z, 0x7FFFFFFF, "Changed to highest possible value (underflow)")
  equal( resultState.cc, oldState.cc, "No change in CC Register" )
  equal( resultState.ccFlags, 0x3, "Indicates negative + overflow" )

test "FunctionCode 13: X*Y->Z", ->
  alu.setFunctionCode 13
  alu.setXRegister 47
  alu.setYRegister 11
  oldState = alu.getState()
  alu.compute()
  resultState = alu.getState()
  equal( resultState.x, oldState.x, "No change in X Register" )
  equal( resultState.y, oldState.y, "No change in Y Register" )
  equal( resultState.z, oldState.x * oldState.y, "Changed to X*Y" )
  equal( resultState.cc, oldState.cc, "No change in CC Register" )
  equal( resultState.ccFlags, 0x4, "Indicates positive" )

test "FunctionCode 13: X*Y->Z, overflow", ->
  alu.setFunctionCode 13
  alu.setXRegister 2
  alu.setYRegister 0x7FFFFFFF
  oldState = alu.getState()
  alu.compute()
  resultState = alu.getState()
  equal( resultState.x, oldState.x, "No change in X Register" )
  equal( resultState.y, oldState.y, "No change in Y Register" )
  equal( resultState.z, 0xFFFFFFFE, "Changed 0xFFFFFFFE")
  equal( resultState.cc, oldState.cc, "No change in CC Register" )
  equal( resultState.ccFlags, 0x5, "Indicates positive + overflow" )

test "FunctionCode 13: X*Y->Z, underflow", ->
  alu.setFunctionCode 13
  alu.setXRegister 0x80000000
  alu.setYRegister 0x2
  oldState = alu.getState()
  alu.compute()
  resultState = alu.getState()
  equal( resultState.x, oldState.x, "No change in X Register" )
  equal( resultState.y, oldState.y, "No change in Y Register" )
  equal( resultState.z, 0, "Changed to 0")
  equal( resultState.cc, oldState.cc, "No change in CC Register" )
  equal( resultState.ccFlags, 0x3, "Indicates negative + overflow" )

test "FunctionCode 14: X/Y->Z when |X| > |Y|", ->
  alu.setFunctionCode 14
  alu.setXRegister 18
  alu.setYRegister 0x9
  oldState = alu.getState()
  alu.compute()
  resultState = alu.getState()
  equal( resultState.x, oldState.x, "No change in X Register" )
  equal( resultState.y, oldState.y, "No change in Y Register" )
  equal( resultState.z, 2, "Changed to 2")
  equal( resultState.cc, oldState.cc, "No change in CC Register" )
  equal( resultState.ccFlags, 0x4, "Indicates positive" )

test "FunctionCode 14: X/Y->Z when |X| > |Y| and negative result", ->
  alu.setFunctionCode 14
  alu.setXRegister 1
  alu.setYRegister 0xFFFFFFFF
  oldState = alu.getState()
  alu.compute()
  resultState = alu.getState()
  equal( resultState.x, oldState.x, "No change in X Register" )
  equal( resultState.y, oldState.y, "No change in Y Register" )
  equal( resultState.z, 0xFFFFFFFF, "Changed to -1")
  equal( resultState.cc, oldState.cc, "No change in CC Register" )
  equal( resultState.ccFlags, 0x2, "Indicates negative" )

test "FunctionCode 14: X/Y->Z when |X| < |Y|", ->
  alu.setFunctionCode 14
  alu.setXRegister 0x1
  alu.setYRegister 0x9
  oldState = alu.getState()
  alu.compute()
  resultState = alu.getState()
  equal( resultState.x, oldState.x, "No change in X Register" )
  equal( resultState.y, oldState.y, "No change in Y Register" )
  equal( resultState.z, 0, "Changed to 0")
  equal( resultState.cc, oldState.cc, "No change in CC Register" )
  equal( resultState.ccFlags, 0x8, "Indicates zero" )

test "FunctionCode 14: X/Y->Z when Y = 0", ->
  alu.setFunctionCode 14
  alu.setXRegister 0x1
  alu.setYRegister 0x0
  oldState = alu.getState()
  alu.compute()
  resultState = alu.getState()
  equal( resultState.x, oldState.x, "No change in X Register" )
  equal( resultState.y, oldState.y, "No change in Y Register" )
  equal( resultState.z, oldState.z, "No change in Z Register")
  equal( resultState.cc, oldState.cc, "No change in CC Register" )
  equal( resultState.ccFlags, Utils.setBit(oldState.ccFlags, 1), "Overflow bit set" )

test "FunctionCode 15: X%Y->Z", ->
  alu.setFunctionCode 15
  alu.setXRegister 0x7
  alu.setYRegister 0x2
  oldState = alu.getState()
  alu.compute()
  resultState = alu.getState()
  equal( resultState.x, oldState.x, "No change in X Register" )
  equal( resultState.y, oldState.y, "No change in Y Register" )
  equal( resultState.z, 1, "Changed to 1")
  equal( resultState.cc, oldState.cc, "No change in CC Register" )
  equal( resultState.ccFlags, 0x4, "Indicates positive" )

test "FunctionCode 15: X%Y->Z when Y = 0", ->
  alu.setFunctionCode 15
  alu.setXRegister 0x7
  alu.setYRegister 0x0
  oldState = alu.getState()
  alu.compute()
  resultState = alu.getState()
  equal( resultState.x, oldState.x, "No change in X Register" )
  equal( resultState.y, oldState.y, "No change in Y Register" )
  equal( resultState.z, oldState.z, "No change in Z Register")
  equal( resultState.cc, oldState.cc, "No change in CC Register" )
  equal( resultState.ccFlags, Utils.setBit(oldState.ccFlags, 1), "Overflow bit set" )

test "FunctionCode 16: X SAL Y->Z", ->
  alu.setFunctionCode 16
  alu.setXRegister 0xE0000002
  alu.setYRegister 0x2
  oldState = alu.getState()
  alu.compute()
  resultState = alu.getState()
  equal( resultState.x, oldState.x, "No change in X Register" )
  equal( resultState.y, oldState.y, "No change in Y Register" )
  equal( resultState.z, 0x80000008, "Changed to 0x80000008")
  equal( resultState.cc, oldState.cc, "No change in CC Register" )
  equal( resultState.ccFlags, 0x2, "Indicates negative" )

test "FunctionCode 17: X SAR Y->Z", ->
  alu.setFunctionCode 17
  alu.setXRegister 0xE0000002
  alu.setYRegister 0x2
  oldState = alu.getState()
  alu.compute()
  resultState = alu.getState()
  equal( resultState.x, oldState.x, "No change in X Register" )
  equal( resultState.y, oldState.y, "No change in Y Register" )
  equal( resultState.z, 0x38000000, "Changed to 0x38000000")
  equal( resultState.cc, oldState.cc, "No change in CC Register" )
  equal( resultState.ccFlags, 0x4, "Indicates positive" )

test "FunctionCode 18: CMP arithm. X Y->Z", ->
  alu.setFunctionCode 18
  alu.setXRegister 47
  alu.setYRegister 11
  oldState = alu.getState()
  alu.compute()
  resultState = alu.getState()
  equal( resultState.x, oldState.x, "No change in X Register" )
  equal( resultState.y, oldState.y, "No change in Y Register" )
  equal( resultState.z, oldState.x - oldState.y, "Changed to X-Y" )
  equal( resultState.cc, oldState.cc, "No change in CC Register" )
  equal( resultState.ccFlags, 0x4, "Indicates positive" )

test "FunctionCode 18: CMP arithm. X Y->Z, overflow", ->
  alu.setFunctionCode 18
  alu.setXRegister 0
  alu.setYRegister 0x80000000
  oldState = alu.getState()
  alu.compute()
  resultState = alu.getState()
  equal( resultState.x, oldState.x, "No change in X Register" )
  equal( resultState.y, oldState.y, "No change in Y Register" )
  equal( resultState.z, 0x80000000, "Changed to least possible value (overflow)")
  equal( resultState.cc, oldState.cc, "No change in CC Register" )
  equal( resultState.ccFlags, 0x5, "Indicates positive + overflow" )

test "FunctionCode 18: CMP arithm. X Y->Z, underflow", ->
  alu.setFunctionCode 18
  alu.setXRegister 0x80000000
  alu.setYRegister 0x1
  oldState = alu.getState()
  alu.compute()
  resultState = alu.getState()
  equal( resultState.x, oldState.x, "No change in X Register" )
  equal( resultState.y, oldState.y, "No change in Y Register" )
  equal( resultState.z, 0x7FFFFFFF, "Changed to highest possible value (underflow)")
  equal( resultState.cc, oldState.cc, "No change in CC Register" )
  equal( resultState.ccFlags, 0x3, "Indicates negative + overflow" )

test "FunctionCode 19: X AND Y->Z", ->
  alu.setFunctionCode 19
  alu.setXRegister 0xFFFFFFFF
  alu.setYRegister 0xFF
  oldState = alu.getState()
  alu.compute()
  resultState = alu.getState()
  equal( resultState.x, oldState.x, "No change in X Register" )
  equal( resultState.y, oldState.y, "No change in Y Register" )
  equal( resultState.z, 0xFF, "Changed to 0xFF")
  equal( resultState.cc, oldState.cc, "No change in CC Register" )
  equal( resultState.ccFlags, 0x4, "Indicates positive" )

test "FunctionCode 20: X NAND Y->Z", ->
  alu.setFunctionCode 20
  alu.setXRegister 0xFFFFFFFF
  alu.setYRegister 0xFF
  oldState = alu.getState()
  alu.compute()
  resultState = alu.getState()
  equal( resultState.x, oldState.x, "No change in X Register" )
  equal( resultState.y, oldState.y, "No change in Y Register" )
  equal( resultState.z, 0xFFFFFF00, "Changed to 0xFFFFFF00")
  equal( resultState.cc, oldState.cc, "No change in CC Register" )
  equal( resultState.ccFlags, 0x2, "Indicates negative" )

test "FunctionCode 21: X OR Y->Z", ->
  alu.setFunctionCode 21
  alu.setXRegister 0xFFFFFF00
  alu.setYRegister 0xFF
  oldState = alu.getState()
  alu.compute()
  resultState = alu.getState()
  equal( resultState.x, oldState.x, "No change in X Register" )
  equal( resultState.y, oldState.y, "No change in Y Register" )
  equal( resultState.z, 0xFFFFFFFF, "Changed to 0xFFFFFFFF")
  equal( resultState.cc, oldState.cc, "No change in CC Register" )
  equal( resultState.ccFlags, 0x2, "Indicates negative" )

test "FunctionCode 22: X NOR Y->Z", ->
  alu.setFunctionCode 22
  alu.setXRegister 0xFFFFFF00
  alu.setYRegister 0xFF
  oldState = alu.getState()
  alu.compute()
  resultState = alu.getState()
  equal( resultState.x, oldState.x, "No change in X Register" )
  equal( resultState.y, oldState.y, "No change in Y Register" )
  equal( resultState.z, 0x00, "Changed to 0x0")
  equal( resultState.cc, oldState.cc, "No change in CC Register" )
  equal( resultState.ccFlags, 0x8, "Indicates zero" )

test "FunctionCode 23: X XOR Y->Z", ->
  alu.setFunctionCode 23
  alu.setXRegister 0xFFFFFFFF
  alu.setYRegister 0xFF0000FF
  oldState = alu.getState()
  alu.compute()
  resultState = alu.getState()
  equal( resultState.x, oldState.x, "No change in X Register" )
  equal( resultState.y, oldState.y, "No change in Y Register" )
  equal( resultState.z, 0x00FFFF00, "Changed to 0x00FFFF00")
  equal( resultState.cc, oldState.cc, "No change in CC Register" )
  equal( resultState.ccFlags, 0x4, "Indicates positive" )

test "FunctionCode 24: X NXOR Y->Z", ->
  alu.setFunctionCode 24
  alu.setXRegister 0xFFFFFFFF
  alu.setYRegister 0xFF0000FF
  oldState = alu.getState()
  alu.compute()
  resultState = alu.getState()
  equal( resultState.x, oldState.x, "No change in X Register" )
  equal( resultState.y, oldState.y, "No change in Y Register" )
  equal( resultState.z, 0xFF0000FF, "Changed to 0xFF0000FF")
  equal( resultState.cc, oldState.cc, "No change in CC Register" )
  equal( resultState.ccFlags, 0x2, "Indicates negative" )

test "FunctionCode 25: X SLL Y->Z", ->
  alu.setFunctionCode 25
  alu.setXRegister 0xF0000000
  alu.setYRegister 0x4
  oldState = alu.getState()
  alu.compute()
  resultState = alu.getState()
  equal( resultState.x, oldState.x, "No change in X Register" )
  equal( resultState.y, oldState.y, "No change in Y Register" )
  equal( resultState.z, 0xF, "Changed to 0xF")
  equal( resultState.cc, oldState.cc, "No change in CC Register" )
  equal( resultState.ccFlags, 0x4, "Indicates positive" )

test "FunctionCode 26: X SLR Y->Z", ->
  alu.setFunctionCode 26
  alu.setXRegister 0x0000000F
  alu.setYRegister 0x4
  oldState = alu.getState()
  alu.compute()
  resultState = alu.getState()
  equal( resultState.x, oldState.x, "No change in X Register" )
  equal( resultState.y, oldState.y, "No change in Y Register" )
  equal( resultState.z, 0xF0000000, "Changed to 0xF0000000")
  equal( resultState.cc, oldState.cc, "No change in CC Register" )
  equal( resultState.ccFlags, 0x2, "Indicates negative" )

test "FunctionCode 27: CMP log. X Y->Z when X > Y", ->
  alu.setFunctionCode 27
  alu.setXRegister 0xF
  alu.setYRegister 0xE
  oldState = alu.getState()
  alu.compute()
  resultState = alu.getState()
  equal( resultState.x, oldState.x, "No change in X Register" )
  equal( resultState.y, oldState.y, "No change in Y Register" )
  equal( resultState.z, 0x1, "Changed to 0x1")
  equal( resultState.cc, oldState.cc, "No change in CC Register" )
  equal( resultState.ccFlags, 0x4, "Indicates positive" )

test "FunctionCode 27: CMP log. X Y->Z when X < Y", ->
  alu.setFunctionCode 27
  alu.setXRegister 0xE
  alu.setYRegister 0xF
  oldState = alu.getState()
  alu.compute()
  resultState = alu.getState()
  equal( resultState.x, oldState.x, "No change in X Register" )
  equal( resultState.y, oldState.y, "No change in Y Register" )
  equal( resultState.z, 0xFFFFFFFF, "Changed to 0xFFFFFFFF")
  equal( resultState.cc, oldState.cc, "No change in CC Register" )
  equal( resultState.ccFlags, 0x2, "Indicates negative" )

test "FunctionCode 28: 0->X", ->
  alu.setFunctionCode 28
  oldState = alu.getState()
  alu.compute()
  resultState = alu.getState()

  equal( resultState.x, 0, "Changed to 0" )
  equal( resultState.y, oldState.y, "No change in Y Register" )
  equal( resultState.z, oldState.z, "No change in Z Register" )
  equal( resultState.cc, oldState.cc, "No change in CC Register" )
  equal( resultState.ccFlags, oldState.ccFlags, "No change in CC Flags" )

test "FunctionCode 29: 0xFFFFFFFF->X", ->
  alu.setFunctionCode 29
  oldState = alu.getState()
  alu.compute()
  resultState = alu.getState()

  equal( resultState.x, 0xFFFFFFFF, "Changed to 0xFFFFFFFF" )
  equal( resultState.y, oldState.y, "No change in Y Register" )
  equal( resultState.z, oldState.z, "No change in Z Register" )
  equal( resultState.cc, oldState.cc, "No change in CC Register" )
  equal( resultState.ccFlags, oldState.ccFlags, "No change in CC Flags" )

test "FunctionCode 30: 0->Y", ->
  alu.setFunctionCode 30
  oldState = alu.getState()
  alu.compute()
  resultState = alu.getState()

  equal( resultState.x, oldState.x, "No change in X Register")
  equal( resultState.y, 0, "Changed to 0")
  equal( resultState.z, oldState.z, "No change in Z Register" )
  equal( resultState.cc, oldState.cc, "No change in CC Register" )
  equal( resultState.ccFlags, oldState.ccFlags, "No change in CC Flags" )

test "FunctionCode 31: 0xFFFFFFFF->Y", ->
  alu.setFunctionCode 31
  oldState = alu.getState()
  alu.compute()
  resultState = alu.getState()

  equal( resultState.x, oldState.x, "No change in X Register" )
  equal( resultState.y, 0xFFFFFFFF, "Changed to 0xFFFFFFFF" )
  equal( resultState.z, oldState.z, "No change in Z Register" )
  equal( resultState.cc, oldState.cc, "No change in CC Register" )
  equal( resultState.ccFlags, oldState.ccFlags, "No change in CC Flags" )

test "FunctionCode 32-47: FC-32->X, X->Z", ->
  for fc in [32..47]
    alu.setFunctionCode fc
    oldState = alu.getState()
    alu.compute()
    resultState = alu.getState()
    ccval = if fc is 32 then 0x8 else 0x4

    equal( resultState.x, fc - 32, "Changed to fc - 32" )
    equal( resultState.y, oldState.y, "No change in Y Register" )
    equal( resultState.z, fc - 32, "Changed to fc - 32" )
    equal( resultState.cc, oldState.cc, "No change in CC Register" )
    equal( resultState.ccFlags, ccval, "Changed to #{ccval}" )

test "FunctionCode 48-63: FC-48->Y, Y->Z", ->
  for fc in [48..63]
    alu.setFunctionCode fc
    oldState = alu.getState()
    alu.compute()
    resultState = alu.getState()
    ccval = if fc is 48 then 0x8 else 0x4
    
    equal( resultState.x, oldState.x, "No change in X Register" )
    equal( resultState.y, fc - 48, "Changed to fc - 32" )
    equal( resultState.z, fc - 48, "Changed to fc - 32" )
    equal( resultState.cc, oldState.cc, "No change in CC Register" )
    equal( resultState.ccFlags, ccval, "Changed to #{ccval}" )