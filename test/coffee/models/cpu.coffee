module("CPU")

test "setMicrocode updates ram mode and format", ->
  mockAlu = mock(Alu)
  mockRam = mock(Ram)
  mockMac = mock(Mac)
  mockRom = mock(Rom)
  cpu = new Cpu(mockAlu, mockRam, mockMac, mockRom)
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
  mockRom = mock(Rom)
  cpu = new Cpu(mockAlu, mockRam, mockMac, mockRom)
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
  mockRom = mock(Rom)
  cpu = new Cpu(mockAlu, mockRam, mockMac, mockRom)
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
  mockRom = mock(Rom)
  cpu = new Cpu(mockAlu, mockRam, mockMac, mockRom)
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
  mockRom = mock(Rom)
  cpu = new Cpu(mockAlu, mockRam, mockMac, mockRom)
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
  verify(mockAlu).setXRegister(8)
  ok(true)

test "GetPhase ybus sets Y register", ->
  mockAlu = mock(Alu)
  mockRam = mock(Ram)
  mockMac = mock(Mac)
  mockRom = mock(Rom)
  cpu = new Cpu(mockAlu, mockRam, mockMac, mockRom)
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
  verify(mockAlu).setYRegister(8)
  ok(true)

test "GetPhase ioswitch bit 5 sets Y register", ->
  mockAlu = mock(Alu)
  mockRam = mock(Ram)
  JsMockito.when(mockRam).getMdr().thenReturn(42)
  mockMac = mock(Mac)
  mockRom = mock(Rom)
  cpu = new Cpu(mockAlu, mockRam, mockMac, mockRom)
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
  mockRom = mock(Rom)
  cpu = new Cpu(mockAlu, mockRam, mockMac, mockRom, [mockListener])
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
  mockRom = mock(Rom)
  cpu = new Cpu(mockAlu, mockRam, mockMac, mockRom, [mockListener])
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
  verify(mockListener).onSignal("X", 7)
  ok(true)

test "GetPhase ybus notifies listeners", ->
  mockAlu = mock(Alu)
  mockRam = mock(Ram)
  mockListener = mock(CpuListener)
  mockMac = mock(Mac)
  mockRom = mock(Rom)
  cpu = new Cpu(mockAlu, mockRam, mockMac, mockRom, [mockListener])
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
  verify(mockListener).onSignal("Y", 7)
  ok(true)

test "GetPhase ioswitch bit 4 sets MCOP register", ->
  mockAlu = mock(Alu)
  mockRam = mock(Ram)
  JsMockito.when(mockRam).getMdr().thenReturn(32810)
  mockMac = mock(Mac)
  mockRom = mock(Rom)
  cpu = new Cpu(mockAlu, mockRam, mockMac, mockRom)
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
  mockRom = mock(Rom)
  cpu = new Cpu(mockAlu, mockRam, mockMac, mockRom, [mockListener])
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
  mockRom = mock(Rom)
  cpu = new Cpu(mockAlu, mockRam, mockMac, mockRom)
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
  mockRom = mock(Rom)
  cpu = new Cpu(mockAlu, mockRam, mockMac, mockRom, [mockListener])
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
  verify(mockListener).onSignal("MCN", "MICROCODE")
  ok(true)

test "GetPhase sets MAC's mask register", ->
  mockAlu = mock(Alu)
  mockRam = mock(Ram)
  mockMac = mock(Mac)
  mockRom = mock(Rom)
  cpu = new Cpu(mockAlu, mockRam, mockMac, mockRom)
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
  mockRom = mock(Rom)
  cpu = new Cpu(mockAlu, mockRam, mockMac, mockRom, [mockListener])
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
  verify(mockListener).onSignal("MASK", "MICROCODE")
  ok(true)

test "GetPhase sets MAC's mode register", ->
  mockAlu = mock(Alu)
  mockRam = mock(Ram)
  mockMac = mock(Mac)
  mockRom = mock(Rom)
  cpu = new Cpu(mockAlu, mockRam, mockMac, mockRom)
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
  mockRom = mock(Rom)
  cpu = new Cpu(mockAlu, mockRam, mockMac, mockRom, [mockListener])
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
  verify(mockListener).onSignal("MODE", "MICROCODE")
  ok(true)

test "GetPhase sets ALU's function code", ->
  mockAlu = mock(Alu)
  mockRam = mock(Ram)
  mockMac = mock(Mac)
  mockRom = mock(Rom)
  cpu = new Cpu(mockAlu, mockRam, mockMac, mockRom)
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
  mockRom = mock(Rom)
  cpu = new Cpu(mockAlu, mockRam, mockMac, mockRom, [mockListener])
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
  verify(mockListener).onSignal("FC", "MICROCODE")
  ok(true)

test "CalcPhase calls compute in alu", ->
  mockAlu = mock(Alu)
  mockRam = mock(Ram)
  mockMac = mock(Mac)
  mockRom = mock(Rom)
  cpu = new Cpu(mockAlu, mockRam, mockMac, mockRom)
  cpu.runCalcPhase()
  verify(mockAlu).compute()
  ok(true)

test "CalcPhase sets ccRegister in mac", ->
  mockAlu = mock(Alu)
  mockRam = mock(Ram)
  mockMac = mock(Mac)
  JsMockito.when(mockAlu).getCCRegister().thenReturn(42)
  mockRom = mock(Rom)
  cpu = new Cpu(mockAlu, mockRam, mockMac, mockRom)
  cpu.runCalcPhase()
  verify(mockMac).setCC(42)
  ok(true)

test "CalcPhase calls compute in mac", ->
  mockAlu = mock(Alu)
  mockRam = mock(Ram)
  mockMac = mock(Mac)
  mockRom = mock(Rom)
  cpu = new Cpu(mockAlu, mockRam, mockMac, mockRom)
  cpu.runCalcPhase()
  verify(mockMac).compute()
  ok(true)

test "GetPhase sets MCAR in MAC", ->
  mockAlu = mock(Alu)
  mockRam = mock(Ram)
  mockMac = mock(Mac)
  mockRom = mock(Rom)
  JsMockito.when(mockRom).getMcar().thenReturn(42)
  cpu = new Cpu(mockAlu, mockRam, mockMac, mockRom)
  cpu.runGetPhase()
  verify(mockMac).setMcar(42)
  ok(true)

test "GetPhase setMCAR signals listeners", ->
  mockAlu = mock(Alu)
  mockRam = mock(Ram)
  mockMac = mock(Mac)
  mockListener = mock(CpuListener)
  mockRom = mock(Rom)
  cpu = new Cpu(mockAlu, mockRam, mockMac, mockRom, [mockListener])
  cpu.runGetPhase()
  verify(mockListener).onSignal("MACMCAR", "ROMMCAR")
  ok(true)

test "PutPhase ioswitch bit 8 sets mar", ->
  mockAlu = mock(Alu)
  mockRam = mock(Ram)
  mockMac = mock(Mac)
  mockRom = mock(Rom)
  cpu = new Cpu(mockAlu, mockRam, mockMac, mockRom)
  JsMockito.when(mockAlu).getZRegister().thenReturn(42)
  JsMockito.when(mockRom).read().thenReturn(
    mode: 0
    mcnext: 0
    alufc: 0
    xbus: 0
    ybus: 0
    zbus: 0
    ioswitch: 0x80
    byte: 0)
  cpu.setMicrocode(
    mode: 0
    mcnext: 0
    alufc: 0
    xbus: 0
    ybus: 0
    zbus: 0
    ioswitch: 0x80
    byte: 0)
  cpu.runPutPhase()
  verify(mockRam).setMar(42)
  ok(true)

test "PutPhase ioswitch bit 7 sets mdr", ->
  mockAlu = mock(Alu)
  mockRam = mock(Ram)
  mockMac = mock(Mac)
  mockRom = mock(Rom)
  cpu = new Cpu(mockAlu, mockRam, mockMac, mockRom)
  JsMockito.when(mockAlu).getZRegister().thenReturn(42)
  JsMockito.when(mockRom).read().thenReturn(
    mode: 0
    mcnext: 0
    alufc: 0
    xbus: 0
    ybus: 0
    zbus: 0
    ioswitch: 0x80
    byte: 0)
  cpu.setMicrocode(
    mode: 0
    mcnext: 0
    alufc: 0
    xbus: 0
    ybus: 0
    zbus: 0
    ioswitch: 0x40
    byte: 0)
  cpu.runPutPhase()
  verify(mockRam).setMdr(42)
  ok(true)

test "PutPhase ioswitch bit 6 sets z", ->
  mockAlu = mock(Alu)
  mockRam = mock(Ram)
  mockMac = mock(Mac)
  mockRom = mock(Rom)
  cpu = new Cpu(mockAlu, mockRam, mockMac, mockRom)
  JsMockito.when(mockRam).getMdr().thenReturn(42)
  JsMockito.when(mockRom).read().thenReturn(
    mode: 0
    mcnext: 0
    alufc: 0
    xbus: 0
    ybus: 0
    zbus: 0
    ioswitch: 0x80
    byte: 0)
  cpu.setMicrocode(
    mode: 0
    mcnext: 0
    alufc: 0
    xbus: 0
    ybus: 0
    zbus: 0
    ioswitch: 0x20
    byte: 0)
  cpu.runPutPhase()
  verify(mockAlu).setZRegister(42)
  ok(true)

test "PutPhase ioswitch bit 3 sets z", ->
  mockAlu = mock(Alu)
  mockRam = mock(Ram)
  mockMac = mock(Mac)
  mockRom = mock(Rom)
  cpu = new Cpu(mockAlu, mockRam, mockMac, mockRom)
  JsMockito.when(mockRam).getMar().thenReturn(42)
  JsMockito.when(mockRom).read().thenReturn(
    mode: 0
    mcnext: 0
    alufc: 0
    xbus: 0
    ybus: 0
    zbus: 0
    ioswitch: 0x80
    byte: 0)
  cpu.setMicrocode(
    mode: 0
    mcnext: 0
    alufc: 0
    xbus: 0
    ybus: 0
    zbus: 0
    ioswitch: 0x4
    byte: 0)
  cpu.runPutPhase()
  verify(mockAlu).setZRegister(42)
  ok(true)

test "PutPhase ioswitch bit 1,2 = 2 triggers write", ->
  mockAlu = mock(Alu)
  mockRam = mock(Ram)
  mockMac = mock(Mac)
  mockRom = mock(Rom)
  cpu = new Cpu(mockAlu, mockRam, mockMac, mockRom)
  JsMockito.when(mockRam).getMar().thenReturn(42)
  JsMockito.when(mockRom).read().thenReturn(
    mode: 0
    mcnext: 0
    alufc: 0
    xbus: 0
    ybus: 0
    zbus: 0
    ioswitch: 0x80
    byte: 0)
  cpu.setMicrocode(
    mode: 0
    mcnext: 0
    alufc: 0
    xbus: 0
    ybus: 0
    zbus: 0
    ioswitch: 0x2
    byte: 0)
  cpu.runPutPhase()
  verify(mockRam).write()
  ok(true)

test "PutPhase zbus sets registers", ->
  mockAlu = mock(Alu)
  mockRam = mock(Ram)
  mockMac = mock(Mac)
  mockRom = mock(Rom)
  cpu = new Cpu(mockAlu, mockRam, mockMac, mockRom)
  JsMockito.when(mockAlu).getZRegister().thenReturn(42)
  JsMockito.when(mockRom).read().thenReturn(
    mode: 0
    mcnext: 0
    alufc: 0
    xbus: 0
    ybus: 0
    zbus: 0
    ioswitch: 0x80
    byte: 0)
  cpu.setMicrocode(
    mode: 0
    mcnext: 0
    alufc: 0
    xbus: 0
    ybus: 0
    zbus: 0xFF
    ioswitch: 0x2
    byte: 0)
  cpu.runPutPhase()
  deepEqual(cpu.registers, [42,42,42,42,42,42,42,42], "all should be 42")

test "PutPhase retrieves next microcode", ->
  mc =
    mode: 0
    mcnext: 0
    alufc: 0
    xbus: 0
    ybus: 0
    zbus: 0
    ioswitch: 0x80
    byte: 0
  mockAlu = mock(Alu)
  mockRam = mock(Ram)
  mockMac = mock(Mac)
  mockRom = mock(Rom)
  cpu = new Cpu(mockAlu, mockRam, mockMac, mockRom)
  JsMockito.when(mockRom).read().thenReturn(mc)
  cpu.setMicrocode(
    mode: 0
    mcnext: 0
    alufc: 0
    xbus: 0
    ybus: 0
    zbus: 0
    ioswitch: 0
    byte: 0)
  cpu.runPutPhase()
  verify(mockRom).read()
  ok(true)

test "Integration Test: Simple Run", ->
  rom = new Rom()
  alu = new Alu()
  ram = new Ram()
  mac = new Mac()
  cpu = new Cpu(alu, ram, mac, rom)
  mc1 =
    mode: 1 # mcar+1+4xmcn
    mcnext: 0x0 # mcn auf 0
    alufc: 0x28 # Z = 8
    xbus: 0
    ybus: 0
    zbus: 0x1 # 8->r7
    ioswitch: 0
    byte: 0
  mc2 =
    mode: 1 # mcar+1+4xmcn
    mcnext: 0x0 # mcn auf 0
    alufc: 0xB # +8
    xbus: 0x1
    ybus: 0x1
    zbus: 0x1 # 8->r7
    ioswitch: 0xC2 # write at 16
    byte: 0
  cpu.setMicrocode(mc1)
  rom.setMicrocode(0, mc1)
  rom.setMicrocode(1, mc2)
  cpu.runTact()
  cpu.runTact()
  equal(ram.getByte(0x10), 0x10, "should be equal")

test "reset", ->
  microcode_at_0 = 42

  mockAlu = mock(Alu)
  mockRam = mock(Ram)
  mockMac = mock(Mac)
  mockRom = mock(Rom)
  JsMockito.when(mockRom).getMicrocode(0).thenReturn(microcode_at_0)

  cpu = new Cpu(mockAlu, mockRam, mockMac, mockRom)

  cpu.reset()

  verify(mockAlu).reset()
  verify(mockRam).reset()
  verify(mockMac).reset()
  verify(mockRom).reset()
  verify(mockRom).getMicrocode(0)
  equal(cpu.microcode, microcode_at_0, "cpu loads microcode at address 0")
