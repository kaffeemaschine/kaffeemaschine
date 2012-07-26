module("ALU")

alu = new Alu();

test "FunctionCode 0: NOP", ->
  alu.setFunctionCode 1
  oldState = alu.getState();
  alu.compute();
  resultState = alu.getState();
  
  # is there sth. like deepEquals?
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
  
  # is there sth. like deepEquals?
  equal( resultState.x, oldState.y, "Swapped with Y Register" );
  equal( resultState.y, oldState.x, "Swapped with X Register" );
  equal( resultState.z, oldState.z, "No change in Z Register" );
  equal( resultState.cc, oldState.cc, "No change in CC Register" );
  equal( resultState.ccFlags, oldState.ccFlags, "No change in CC Flags" );
  
test "Function 2: Z=Z, X->Y, X=0", ->
  alu.setFunctionCode 2
  alu.setXRegister 1
  alu.setYRegister 2
  oldState = alu.getState();
  alu.compute();
  resultState = alu.getState();
  
  # is there sth. like deepEquals?
  equal( resultState.x, 0, "Reset to 0" );
  equal( resultState.y, oldState.x, "Changed to X Register" );
  equal( resultState.z, oldState.z, "No change in Z Register" );
  equal( resultState.cc, oldState.cc, "No change in CC Register" );
  equal( resultState.ccFlags, oldState.ccFlags, "No change in CC Flags" );