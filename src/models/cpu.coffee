class @Cpu
  constructor: (@alu = new Alu(), @ram = new Ram(), @mac = new Mac(), @rom = new Rom(), @cpuListeners = [], @aluListeners = [], @ramListeners = [], @macListeners = [], @romListeners = []) ->
    @ram.setRamListeners(@ramListeners)
    @alu.setAluListeners(@aluListeners)
    @mac.setMacListeners(@macListeners)
    @rom.setRomListeners(@romListeners)
    # RAM technically not part of cpu... go ahead and kill me
    @registers = [0,0,0,0,0,0,0,0]
    @nextPhase = 0
    @microcode =
      mode: 0
      mcnext: 0
      alufc: 0
      xbus: 0
      ybus: 0
      zbus: 0
      ioswitch: 0
      byte: 0
      mnemonic: ""
      remarks: ""

  setCpuListeners: (l) ->
    @cpuListeners = l

  setMicrocode: (code) ->
    @microcode = code
    #update ram mode and ram format
    @ram.setMode(Utils.extractNum(@microcode.ioswitch, 1, 2))
    @ram.setFormat(@microcode.byte)
    #update alu function code
    @alu.setFunctionCode(@microcode.alufc)

  setRegister: (register, value) ->
    @registers[register] = value
    @notifySetRegister(register, value)

  # run until current tact ends (tact = get- + calc- + put-phase)
  runTact: ->
    @runPhase()
    @runPhase() until @nextPhase is 0

  # run next phase in current tact
  runPhase: ->
    switch @nextPhase
      when 0 then @runGetPhase()
      when 1 then @runCalcPhase()
      when 2 then @runPutPhase()

  # get phase
  runGetPhase: ->
    console.log "running get phase"
    @setMDRFromRam()
    @setXFromReg()
    @setYFromReg()
    @setYFromMDR()
    @setMCOPFromMDR()
    @setMode()
    @setMCN()
    @setMask()
    @setAluFC()
    @setMCAR()

    @setNextPhase()

  #read from ram? (when [46,47] = 01)
  setMDRFromRam: ->
    if Utils.extractNum(@microcode.ioswitch, 1, 2) is 1
      @ram.read()
  # set X in alu from R0-R7
  setXFromReg: ->
    toXFrom = Utils.getLowestBitSet @microcode.xbus, 1, 8
    toXFrom = 8-toXFrom if toXFrom?
    console.log "toXFrom = #{toXFrom}"
    if toXFrom?
      @alu.setXRegister @registers[toXFrom]
      @notifySignal("X", toXFrom)
  # set Y in alu from R0-R7
  setYFromReg: ->
    toYFrom = Utils.getLowestBitSet @microcode.ybus, 1, 8
    toYFrom = 8-toYFrom if toYFrom?
    if toYFrom?
      @alu.setYRegister @registers[toYFrom]
      @notifySignal("Y", toYFrom)
  # set Y in alu from RAM
  setYFromMDR: ->
    if Utils.isBitSet(@microcode.ioswitch, 5) is on
      @alu.setYRegister @ram.getMdr()
      @notifySignal("Y", "MDR")
  setMCOPFromMDR: ->
    # gui says this happens in phase 3, doc says phase 1, program says phase 1
    if Utils.isBitSet(@microcode.ioswitch, 4) is on
      @mac.setMcop Utils.extractNum(@ram.getMdr(), 1, 8)
      @notifySignal("MCOP", "MDR")
  setMode: ->
    @mac.setMode(@microcode.mode)
    @notifySignal("MODE", "MICROCODE")
  setMCN: ->
    @mac.setMcn(@microcode.mcnext)
    @notifySignal("MCN", "MICROCODE")
  setMask: ->
    @mac.setMask(Utils.extractNum(@microcode.mcnext, 1, 4))
    @notifySignal("MASK", "MICROCODE")
  setAluFC: ->
    console.log "setting alufc #{@microcode.alufc}"
    @alu.setFunctionCode @microcode.alufc
    @notifySignal("FC", "MICROCODE")
  setMCAR: ->
    @mac.setMcar @rom.getMcar()
    @notifySignal("MACMCAR", "ROMMCAR")

  runCalcPhase: ->
    console.log "running calc phase"
    # run alu with given opcode
    @alu.compute()
    # set mac cc register
    @mac.setCC(@alu.getCCRegister())
    # compute mcar next
    @mac.compute()
    @setNextPhase()

  runPutPhase: ->
    console.log "running put phase"
    # TODO
    @setNextPhase()

  setNextPhase: ->
    @nextPhase = (@nextPhase + 1) % 3
    @notifyNextPhase(@nextPhase)

  notifySignal: (to, from) ->
    listener.onSignal?(to, from) for listener in @cpuListeners

  notifyNextPhase: (phase) ->
    listener.onNextPhase?(phase) for listener in @cpuListeners

  notifySetRegister: (register, value) ->
    listener.onSetRegister?(register, value) for listener in @cpuListeners

  # resets alu and mac
  reset: ->
    @alu.reset()
    @mac.reset()
    @ram.reset()
    @rom.reset()
    console.log("foooooooooooooooooooooo")
    @microcode = @rom.getMicrocode 0
