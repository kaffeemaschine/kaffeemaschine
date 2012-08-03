module("ROM")

romListener = new RomListener()
rom = new Rom([romListener])

asyncTest "SetMicrocode notifies listeners", ->
  microcode =
      mode: 1
      mcnext: 2
      alufc: 3
      xbus: 4
      ybus: 5
      zbus: 6
      ioswitch: 7
      byte: 8
      mnemonic: "9"
      remarks: "0"
  
  romListener.setOnSetMc((at, mc) ->
    equal(at, 5, "at should be 5")
    deepEqual(mc, microcode, "MC should've been equal")

    romListener.setOnSetMc(undefined)
    start()
    )

  rom.setMicrocode(5, microcode)

asyncTest "SetMcar notifies listeners", ->
  mcar = 42
  
  romListener.setOnSetMcar((m) ->
    equal(m, mcar, "mcar should be 42")

    romListener.setOnSetMcar(undefined)
    start()
    )

  rom.setMcar(mcar)

test "SetMicrocode sets Microcode", ->
  microcode =
      mode: 1
      mcnext: 2
      alufc: 3
      xbus: 4
      ybus: 5
      zbus: 6
      ioswitch: 7
      byte: 8
      mnemonic: "9"
      remarks: "0"

  rom.setMicrocode(5, microcode)
  deepEqual(rom.memory[5], microcode, "MC should've been set")

test "SetMcar sets MCAR", ->
  mcar = 53

  rom.setMcar(mcar)
  equal(rom.mcar, mcar, "MCAR should've been set")

test "read return microcode @ address mcar", ->
  microcode =
      mode: 1
      mcnext: 2
      alufc: 3
      xbus: 4
      ybus: 5
      zbus: 6
      ioswitch: 7
      byte: 8
      mnemonic: "9"
      remarks: "0"

  rom.setMicrocode(5, microcode)
  rom.setMcar(5)
  deepEqual(rom.read(), microcode, "MC should've been equal")

test "reset", ->
  rom.reset()
  equal(rom.mcar, 0, "mcar initial 0")
