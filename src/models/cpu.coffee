class @Cpu
  constructor: (@alu = new Alu(), @ram = new Ram(), @cpuListeners = [], @aluListeners = [], @ramListeners = []) ->
    @ram.setRamListeners(@ramListeners)
    @alu.setAluListeners(@aluListeners)
    # RAM technically not part of cpu... go ahead and kill me
    @registers = [0,0,0,0,0,0,0,0]
    @nextPhase = 0
    @microcode = 0

  setMicrocode: (code) ->
    @microcode = code
    #update ram mode and ram format
    @ram.setMode(Utils.extractNum(@microcode, 46, 47))
    @ram.setFormat(Utils.extractNum(@microcode, 48, 49))
    #update alu function code
    @alu.setFunctionCode(Utils.extractNum(@microcode, 9, 16)) 

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
    @setMCN()
    @setMask()
    @setAluFC()
    @setMCDR()
    
    @setNextPhase()

  #read from ram? (when [46,47] = 01
  setMDRFromRam: ->
    if Utils.extractNum(@microcode, 46, 47) is 1
      @ram.read()
  # set X in alu from R0-R7
  setXFromReg: ->
    toXFrom = Utils.getHighestBitSet @microcode, 16, 23
    toXFrom -= 16 if toXFrom?
    if toXFrom?
      @alu.setXRegister @registers[toXFrom]
      @notifySignal("X", toXFrom)  
  # set X in alu from R0-R7
  setYFromReg: ->
    toYFrom = @highestBitSet @microcode, 24, 31
    toYFrom -= 24 if toYFrom?
    if toYFrom?
      @alu.setYRegister @registers[toYFrom]
      @notifySignal("Y", toYFrom)
  # set Y in alu from RAM
  setYFromMDR: ->
    if Utils.isBitSet(@microcode, 43) is on
      @alu.setYRegister @ram.getMdr()
      @notifySignal("X", "MDR")
  setMCOPFromMDR: ->
      #TODO
  setMCN: ->
      #TODO
  setMask: ->
      #TODO
  setAluFC: ->
      #TODO
  setMCDR: ->
      #TODO
    
  runCalcPhase: ->
    console.log "running calc phase"
    # run alu with given opcode
    # TODO
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