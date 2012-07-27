module("CPU")

test "setMicrocode updates ram mode and format", ->
  mockAlu = mock(Alu)
  mockRam = mock(Ram)
  mockMac = mock(Mac)
  cpu = new Cpu(mockAlu, mockRam, mockMac);
  cpu.setMicrocode(
    mode: 0
    mcnext: 0
    alufc: 0
    xbus: 0
    ybus: 0
    zbus: 0
    ioswitch: 2
    byte: 1)
  verify(mockRam).setMode(2)
  verify(mockRam).setFormat(1)
  ok(true)

test "setMicrocode updates alu function code", ->
  mockAlu = mock(Alu)
  mockRam = mock(Ram)
  mockMac = mock(Mac)
  cpu = new Cpu(mockAlu, mockRam, mockMac);
  cpu.setMicrocode(
    mode: 0
    mcnext: 0
    alufc: 42
    xbus: 0
    ybus: 0
    zbus: 0
    ioswitch: 0
    byte: 0)
  verify(mockAlu).setFunctionCode(42)
  ok(true)

test "GetPhase triggers RAM read if read mode is on", ->
  mockAlu = mock(Alu)
  mockRam = mock(Ram)
  mockMac = mock(Mac)
  cpu = new Cpu(mockAlu, mockRam, mockMac);
  cpu.setMicrocode(
    mode: 0
    mcnext: 0
    alufc: 0
    xbus: 0
    ybus: 0
    zbus: 0
    ioswitch: 1
    byte: 0)
  cpu.runGetPhase()
  verify(mockRam).read()
  ok(true)

test "GetPhase doesn't trigger RAM read if read mode is off", ->
  mockAlu = mock(Alu)
  mockRam = mock(Ram)
  mockMac = mock(Mac)
  cpu = new Cpu(mockAlu, mockRam, mockMac);
  cpu.setMicrocode(
    mode: 0
    mcnext: 0
    alufc: 0
    xbus: 0
    ybus: 0
    zbus: 0
    ioswitch: 0
    byte: 0)
  cpu.runGetPhase()
  verify(mockRam, times(0)).read()
  ok(true)

test "GetPhase xbus sets X register", ->
  mockAlu = mock(Alu)
  mockRam = mock(Ram)
  mockMac = mock(Mac)
  cpu = new Cpu(mockAlu, mockRam, mockMac);
  cpu.setRegister(0,1)
  cpu.setRegister(1,2)
  cpu.setRegister(2,3)
  cpu.setRegister(3,4)
  cpu.setRegister(4,5)
  cpu.setRegister(5,6)
  cpu.setRegister(6,7)
  cpu.setRegister(7,8)
  cpu.setMicrocode(
    mode: 0
    mcnext: 0
    alufc: 0
    xbus: 0xFF
    ybus: 0
    zbus: 0
    ioswitch: 0
    byte: 0)
  cpu.runGetPhase()
  verify(mockAlu).setXRegister(1)
  ok(true)

test "GetPhase ybus sets Y register", ->
  mockAlu = mock(Alu)
  mockRam = mock(Ram)
  mockMac = mock(Mac)
  cpu = new Cpu(mockAlu, mockRam, mockMac);
  cpu.setRegister(0,1)
  cpu.setRegister(1,2)
  cpu.setRegister(2,3)
  cpu.setRegister(3,4)
  cpu.setRegister(4,5)
  cpu.setRegister(5,6)
  cpu.setRegister(6,7)
  cpu.setRegister(7,8)
  cpu.setMicrocode(
    mode: 0
    mcnext: 0
    alufc: 0
    xbus: 0
    ybus: 0xFF
    zbus: 0
    ioswitch: 0
    byte: 0)
  cpu.runGetPhase()
  verify(mockAlu).setYRegister(1)
  ok(true)

test "GetPhase ioswitch bit 5 sets Y register", ->
  mockAlu = mock(Alu)
  mockRam = mock(Ram)
  JsMockito.when(mockRam).getMdr().thenReturn(42)
  mockMac = mock(Mac)
  cpu = new Cpu(mockAlu, mockRam, mockMac);
  cpu.setMicrocode(
    mode: 0
    mcnext: 0
    alufc: 0
    xbus: 0
    ybus: 0
    zbus: 0
    ioswitch: 16
    byte: 0)
  cpu.runGetPhase()
  verify(mockAlu).setYRegister(42)
  ok(true)

test "GetPhase ioswitch bit 5 notifies listeners", ->
  mockAlu = mock(Alu)
  mockRam = mock(Ram)
  mockListener = mock(CpuListener)
  mockMac = mock(Mac)
  cpu = new Cpu(mockAlu, mockRam, mockMac, [mockListener]);
  JsMockito.when(mockRam).getMdr().thenReturn(42)
  cpu.setMicrocode(
    mode: 0
    mcnext: 0
    alufc: 0
    xbus: 0
    ybus: 0
    zbus: 0
    ioswitch: 16
    byte: 0)
  cpu.runGetPhase()
  verify(mockListener).onSignal("Y", "MDR")
  ok(true)

test "GetPhase xbus notifies listeners", ->
  mockAlu = mock(Alu)
  mockRam = mock(Ram)
  mockListener = mock(CpuListener)
  mockMac = mock(Mac)
  cpu = new Cpu(mockAlu, mockRam, mockMac, [mockListener]);
  cpu.setMicrocode(
    mode: 0
    mcnext: 0
    alufc: 0
    xbus: 3
    ybus: 0
    zbus: 0
    ioswitch: 0
    byte: 0)
  cpu.runGetPhase()
  verify(mockListener).onSignal("X", 6)
  ok(true)

test "GetPhase ybus notifies listeners", ->
  mockAlu = mock(Alu)
  mockRam = mock(Ram)
  mockListener = mock(CpuListener)
  mockMac = mock(Mac)
  cpu = new Cpu(mockAlu, mockRam, mockMac, [mockListener]);
  cpu.setMicrocode(
    mode: 0
    mcnext: 0
    alufc: 0
    xbus: 0
    ybus: 3
    zbus: 0
    ioswitch: 0
    byte: 0)
  cpu.runGetPhase()
  verify(mockListener).onSignal("Y", 6)
  ok(true)

test "GetPhase ioswitch bit 4 sets MCOP register", ->
  mockAlu = mock(Alu)
  mockRam = mock(Ram)
  JsMockito.when(mockRam).getMdr().thenReturn(32810)
  mockMac = mock(Mac)
  cpu = new Cpu(mockAlu, mockRam, mockMac);
  cpu.setMicrocode(
    mode: 0
    mcnext: 0
    alufc: 0
    xbus: 0
    ybus: 0
    zbus: 0
    ioswitch: 8
    byte: 0)
  cpu.runGetPhase()
  verify(mockMac).setMcop(42)
  ok(true)

test "GetPhase ioswitch bit 4 notifies listeners", ->
  mockAlu = mock(Alu)
  mockRam = mock(Ram)
  mockListener = mock(CpuListener)
  JsMockito.when(mockRam).getMdr().thenReturn(32810)
  mockMac = mock(Mac)
  cpu = new Cpu(mockAlu, mockRam, mockMac, [mockListener]);
  cpu.setMicrocode(
    mode: 0
    mcnext: 0
    alufc: 0
    xbus: 0
    ybus: 0
    zbus: 0
    ioswitch: 8
    byte: 0)
  cpu.runGetPhase()
  verify(mockListener).onSignal("MCOP", "MDR")
  ok(true)

test "GetPhase sets MCN register", ->
  mockAlu = mock(Alu)
  mockRam = mock(Ram)
  mockMac = mock(Mac)
  cpu = new Cpu(mockAlu, mockRam, mockMac);
  cpu.setMicrocode(
    mode: 0
    mcnext: 47
    alufc: 0
    xbus: 0
    ybus: 0
    zbus: 0
    ioswitch: 0
    byte: 0)
  cpu.runGetPhase()
  verify(mockMac).setMcn(47)
  ok(true)

test "GetPhase sets MCN register notifies signal", ->
  mockAlu = mock(Alu)
  mockRam = mock(Ram)
  mockMac = mock(Mac)
  mockListener = mock(CpuListener)
  cpu = new Cpu(mockAlu, mockRam, mockMac, [mockListener]);
  cpu.setMicrocode(
    mode: 0
    mcnext: 47
    alufc: 0
    xbus: 0
    ybus: 0
    zbus: 0
    ioswitch: 0
    byte: 0)
  cpu.runGetPhase()
  verify(mockListener).onSignal("MICROCODE", "MCN")
  ok(true)

test "GetPhase sets MAC's mask register", ->
  mockAlu = mock(Alu)
  mockRam = mock(Ram)
  mockMac = mock(Mac)
  cpu = new Cpu(mockAlu, mockRam, mockMac);
  cpu.setMicrocode(
    mode: 0
    mcnext: 63
    alufc: 0
    xbus: 0
    ybus: 0
    zbus: 0
    ioswitch: 0
    byte: 0)
  cpu.runGetPhase()
  verify(mockMac).setMask(15)
  ok(true)

test "GetPhase sets MAC's mask register notifies listeners", ->
  mockAlu = mock(Alu)
  mockRam = mock(Ram)
  mockListener = mock(CpuListener)
  mockMac = mock(Mac)
  cpu = new Cpu(mockAlu, mockRam, mockMac, [mockListener]);
  cpu.setMicrocode(
    mode: 0
    mcnext: 63
    alufc: 0
    xbus: 0
    ybus: 0
    zbus: 0
    ioswitch: 0
    byte: 0)
  cpu.runGetPhase()
  verify(mockListener).onSignal("MICROCODE", "MASK")
  ok(true)

test "GetPhase sets MAC's mode register", ->
  mockAlu = mock(Alu)
  mockRam = mock(Ram)
  mockMac = mock(Mac)
  cpu = new Cpu(mockAlu, mockRam, mockMac);
  cpu.setMicrocode(
    mode: 2
    mcnext: 0
    alufc: 0
    xbus: 0
    ybus: 0
    zbus: 0
    ioswitch: 0
    byte: 0)
  cpu.runGetPhase()
  verify(mockMac).setMode(2)
  ok(true)

test "GetPhase sets MAC's mode register signals listeners", ->
  mockAlu = mock(Alu)
  mockRam = mock(Ram)
  mockListener = mock(CpuListener)
  mockMac = mock(Mac)
  cpu = new Cpu(mockAlu, mockRam, mockMac, [mockListener]);
  cpu.setMicrocode(
    mode: 2
    mcnext: 0
    alufc: 0
    xbus: 0
    ybus: 0
    zbus: 0
    ioswitch: 0
    byte: 0)
  cpu.runGetPhase()
  verify(mockListener).onSignal("MICROCODE", "MODE")
  ok(true)

test "GetPhase sets ALU's function code", ->
  mockAlu = mock(Alu)
  mockRam = mock(Ram)
  mockMac = mock(Mac)
  cpu = new Cpu(mockAlu, mockRam, mockMac);
  cpu.setMicrocode(
    mode: 0
    mcnext: 0
    alufc: 137
    xbus: 0
    ybus: 0
    zbus: 0
    ioswitch: 0
    byte: 0)
  cpu.runGetPhase()
  verify(mockAlu, times(2)).setFunctionCode(137)
  ok(true)

test "GetPhase sets ALU's function code signals listeners", ->
  mockAlu = mock(Alu)
  mockRam = mock(Ram)
  mockMac = mock(Mac)
  mockListener = mock(CpuListener)
  cpu = new Cpu(mockAlu, mockRam, mockMac, [mockListener]);
  cpu.setMicrocode(
    mode: 0
    mcnext: 0
    alufc: 137
    xbus: 0
    ybus: 0
    zbus: 0
    ioswitch: 0
    byte: 0)
  cpu.runGetPhase()
  verify(mockListener).onSignal("MICROCODE", "FC")
  ok(true)