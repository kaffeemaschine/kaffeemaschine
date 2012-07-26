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
  oldState = alu.getState();
  alu.compute();
  resultState = alu.getState();
  
  equal( resultState.x, oldState.x, "No change in X Register" );
  equal( resultState.y, oldState.y, "No change in Y Register" );
  equal( resultState.z, oldState.z, "No change in Z Register" );
  equal( resultState.cc, oldState.cc, "No change in CC Register" );
  equal( resultState.ccFlags, oldState.ccFlags, "No change in CC Flags" );
  
test "FunctionCode 1: X<->Y", ->
  alu.setFunctionCode 1    
  alu.setXRegister 1
  alu.setYRegister 2
  oldState = alu.getState();
  alu.compute();
  resultState = alu.getState();
  
  equal( resultState.x, oldState.y, "Swapped with Y Register" );
  equal( resultState.y, oldState.x, "Swapped with X Register" );
  equal( resultState.z, oldState.z, "No change in Z Register" );
  equal( resultState.cc, oldState.cc, "No change in CC Register" );
  equal( resultState.ccFlags, oldState.ccFlags, "No change in CC Flags" );
  
test "FunctionCode 2: Z=Z, X->Y, X=0", ->
  alu.setFunctionCode 2
  alu.setXRegister 1
  alu.setYRegister 2
  oldState = alu.getState();
  alu.compute();
  resultState = alu.getState();
  
  equal( resultState.x, 0, "Reset to 0" );
  equal( resultState.y, oldState.x, "Changed to X Register" );
  equal( resultState.z, oldState.z, "No change in Z Register" );
  equal( resultState.cc, oldState.cc, "No change in CC Register" );
  equal( resultState.ccFlags, oldState.ccFlags, "No change in CC Flags" );

test "FunctionCode 3: Z=Z, Y->X, Y=0", ->
  alu.setFunctionCode 3
  alu.setXRegister 1
  alu.setYRegister 2
  oldState = alu.getState();
  alu.compute();
  resultState = alu.getState();
  
  equal( resultState.x, oldState.y, "Changed to Y Register" );
  equal( resultState.y, 0, "Reset to 0" );
  equal( resultState.z, oldState.z, "No change in Z Register" );
  equal( resultState.cc, oldState.cc, "No change in CC Register" );
  equal( resultState.ccFlags, oldState.ccFlags, "No change in CC Flags" );

test "FunctionCode 4: Z=X, X is zero", ->
  alu.setFunctionCode 4
  alu.setXRegister 0
  alu.setYRegister 10
  oldState = alu.getState();
  alu.compute();
  resultState = alu.getState();
  
  equal( resultState.x, oldState.x, "No change in X Register" );
  equal( resultState.y, oldState.y, "No change in Y Register" );
  equal( resultState.z, oldState.x, "Changed to X Register" );
  equal( resultState.cc, oldState.cc, "No change in CC Register" );
  equal( resultState.ccFlags, 0x8, "Indicates Zero" );

test "FunctionCode 4: Z=X, X is pos", ->
  alu.setFunctionCode 4
  alu.setXRegister 1
  alu.setYRegister 10
  oldState = alu.getState();
  alu.compute();
  resultState = alu.getState();
  
  equal( resultState.x, oldState.x, "No change in X Register" );
  equal( resultState.y, oldState.y, "No change in Y Register" );
  equal( resultState.z, oldState.x, "Changed to X Register" );
  equal( resultState.cc, oldState.cc, "No change in CC Register" );
  equal( resultState.ccFlags, 0x4, "Indicates positive" );

test "FunctionCode 4: Z=X, X is neg", ->
  alu.setFunctionCode 4
  alu.setXRegister -1
  alu.setYRegister 10
  oldState = alu.getState();
  alu.compute();
  resultState = alu.getState();
  
  equal( resultState.x, oldState.x, "No change in X Register" );
  equal( resultState.y, oldState.y, "No change in Y Register" );
  equal( resultState.z, oldState.x, "Changed to X Register" );
  equal( resultState.cc, oldState.cc, "No change in CC Register" );
  equal( resultState.ccFlags, 0x2, "Indicates negative" );

test "FunctionCode 5: Z=Y, Y is zero", ->
  alu.setFunctionCode 5
  alu.setXRegister 10
  alu.setYRegister 0
  oldState = alu.getState();
  alu.compute();
  resultState = alu.getState();
  
  equal( resultState.x, oldState.x, "No change in X Register" );
  equal( resultState.y, oldState.y, "No change in Y Register" );
  equal( resultState.z, oldState.y, "Changed to Y Register" );
  equal( resultState.cc, oldState.cc, "No change in CC Register" );
  equal( resultState.ccFlags, 0x8, "Indicates Zero" );

test "FunctionCode 5: Z=Y, Y is pos", ->
  alu.setFunctionCode 5
  alu.setXRegister 10
  alu.setYRegister 1
  oldState = alu.getState();
  alu.compute();
  resultState = alu.getState();
  
  equal( resultState.x, oldState.x, "No change in X Register" );
  equal( resultState.y, oldState.y, "No change in Y Register" );
  equal( resultState.z, oldState.y, "Changed to Y Register" );
  equal( resultState.cc, oldState.cc, "No change in CC Register" );
  equal( resultState.ccFlags, 0x4, "Indicates positive" );

test "FunctionCode 5: Z=Y, Y is neg", ->
  alu.setFunctionCode 5
  alu.setXRegister 10
  alu.setYRegister -1
  oldState = alu.getState();
  alu.compute();
  resultState = alu.getState();
  
  equal( resultState.x, oldState.x, "No change in X Register" );
  equal( resultState.y, oldState.y, "No change in Y Register" );
  equal( resultState.z, oldState.y, "Changed to Y Register" );
  equal( resultState.cc, oldState.cc, "No change in CC Register" );
  equal( resultState.ccFlags, 0x2, "Indicates negative" );