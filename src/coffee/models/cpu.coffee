class @Cpu
  constructor: (@alu = new Alu(), @ram = new Ram(), @mac = new Mac(),
      @rom = new Rom(), @cpuListeners = [], aluListeners = [],
      ramListeners = [], macListeners = [], romListeners = []) ->

    @log = Utils.getLogger 'Cpu'

    @ram.setRamListeners ramListeners unless ramListeners is []
    @alu.setAluListeners aluListeners unless aluListeners is []
    @mac.setMacListeners macListeners unless macListeners is []
    @rom.setRomListeners romListeners unless romListeners is []
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
    @log.debug -> "constructor done"


  setCpuListeners: (l) ->
    @cpuListeners = l

  setMicrocodeField: (field, value) ->
    switch field
      when "mode"
        @log.debug -> "setting mc.mode to #{value}"
        @microcode.mode = value
      when "mcnext"
        @log.debug -> "setting mc.mcnext to #{value}"
        @microcode.mcnext = value
      when "alufc"
        @log.debug -> "setting mc.alufc to #{value}"
        @microcode.alufc = value
      when "xbus"
        @log.debug -> "setting mc.xbus to #{value}"
        @microcode.xbus = value
      when "ybus"
        @log.debug -> "setting mc.ybus to #{value}"
        @microcode.ybus = value
      when "zbus"
        @log.debug -> "setting mc.zbus to #{value}"
        @microcode.zbus = value
      when "ioswitch"
        @log.debug -> "setting mc.ioswitch to #{value}"
        @microcode.ioswitch = value
      when "byte"
        @log.debug -> "setting mc.byte to #{value}"
        @microcode.byte = value
      when "mnemonic"
        @log.debug -> "setting mc.mnemonic to #{value}"
        @microcode.mnemonic = value
      when "remarks"
        @log.debug -> "setting mc.remarks to #{value}"
        @microcode.remarks = value
      else
        @log.warning -> "unknown field #{field} in setMicrocodeField."
    @publishMicrocode()


  setMicrocode: (code) ->
    @log.debug -> "setting microcode to\n
                   mode: #{code.mode}\n
                   mcnext: #{code.mcnext}\n
                   alufc: #{code.alufc}\n
                   xbus: #{code.xbus}\n
                   ybus: #{code.ybus}\n
                   zbus: #{code.zbus}\n
                   ioswitch: #{code.ioswitch}\n
                   byte: #{code.byte}\n"
    @microcode = code
    @publishMicrocode()

  publishMicrocode: ->
    #update ram mode and ram format
    @ram.setMode(Utils.extractNum(@microcode.ioswitch, 1, 2))
    @ram.setFormat(@microcode.byte)
    #update alu function code
    @alu.setFunctionCode(@microcode.alufc)
    @notifyMicrocode(@microcode)

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
    @log.info -> "running get phase"
    actions = MicrocodeParser.parseGetPhase @microcode
    @performAction action for action in actions
    @setNextPhase()

  # calc phase
  runCalcPhase: ->
    @log.info -> "running calc phase"
    actions = MicrocodeParser.parseCalcPhase @microcode
    @performAction action for action in actions
    @setNextPhase()

  # put phase
  runPutPhase: ->
    @log.info -> "running put phase"
    actions = MicrocodeParser.parsePutPhase @microcode
    @performAction action for action in actions
    @setNextPhase()

  performAction: (a) ->
    @log.debug -> "performing action=#{a}" 
    [action, rest...] = a.split " "

    

    switch action
      when "compute"
        @log.debug -> "compute..."
        [target] = rest
        @performCompute target
      when "push"
        @log.debug -> "push..."
        [to, from] = rest
        @performPush to, from
      when "pushval"
        @log.debug -> "pushval..."
        [to, value] = rest
        @performPushVal to, value
      when "next"
        @log.debug -> "fetching next microcode"
        @setMicrocode(@rom.read())
      else
        @log.error -> "unknown command: #{action}"
        

  performPush: (to, from) ->
    [fromDomain, fromRegister] = from.split "."
    switch fromDomain
      when "registers"
        value = @registers[parseInt fromRegister]
        @log.debug => "from R#{fromRegister} = #{value}"
      when "ram"
        switch fromRegister
          when "MAR"
            value = @ram.getMar()
            @log.debug => "from ram.MAR = #{value}"
          when "MDR"
            value = @ram.getMdr()
            @log.debug => "from ram.MDR = #{value}"
      when "rom"
        switch fromRegister
          when "MCAR"
            value = @rom.getMcar()
            @log.debug => "from rom.MCAR = #{value}"
      when "mac"
        switch fromRegister
          when "MCARNEXT"
            value = @mac.getMcarNext()
            @log.debug => "from mac.MCARNEXT = #{value}"
      when "alu"
        switch fromRegister
          when "Z"
            value = @alu.getZRegister()
            @log.debug => "from alu.Z = #{value}"
          when "CC"
            value = @alu.getCCRegister()
            @log.debug => "from alu.CC = #{value}"

    if value is undefined
      @log.error -> "unknown push source: #{from}"
      @log.debug -> "...push failed"
      return
    
    if @setTarget(to, value) is true
      @log.debug -> "notify push signal"
      @notifySignal(to, from)
      @log.debug -> "...push ok"
    else
      @log.error -> "unknown push target: #{to}"
      @log.debug -> "...push failed"

  performPushVal: (to, value) ->
    if @setTarget(to, parseInt value) is true
      @log.debug -> "notify pushval signal"
      @notifySignal(to, "MICROCODE")
      @log.debug -> "...pushval ok"
    else
      @log.error -> "unknown pushval target: #{to}"
      @log.debug -> "...pushval failed"

  setTarget: (target, value) ->
    [toDomain, toRegister] = target.split "."
    targetError = false
    switch toDomain
      when "registers"
        @log.debug => "to R#{parseInt toRegister}"
        @registers[parseInt toRegister] = value        
      when "ram"
        switch toRegister
          when "MAR"
            @log.debug -> "to ram.MAR"
            @ram.setMar value
          when "MDR"
            @log.debug -> "to ram.MDR"
            @ram.setMdr value
          else
            targetError = true
      when "rom"
        switch toRegister
          when "MCAR"
            @log.debug -> "to rom.MCAR"
            @rom.setMcar value
          else
            targetError = true
      when "alu"
        switch toRegister
          when "X"
            @log.debug -> "to alu.X"
            @alu.setXRegister value
          when "Y"
            @log.debug -> "to alu.Y"
            @alu.setYRegister value
          when "Z"
            @log.debug -> "to alu.Z"
            @alu.setZRegister value
          when "FC"
            @log.debug -> "to alu.FC"
            @alu.setFunctionCode value
          else
            targetError = true
      when "mac"
        switch toRegister
          when "MCOP"
            @log.debug -> "to mac.MCOP"
            @mac.setMcop value
          when "MCAR"
            @log.debug -> "to mac.MCAR"
            @mac.setMcar value
          when "mode"
            @log.debug -> "to mac.mode"
            @mac.setMode value
          when "MCN"
            @log.debug -> "to mac.MCN"
            @mac.setMcn value
          when "MASK"
            @log.debug -> "to mac.MASK"
            @mac.setMask value
          when "CC"
            @log.debug => "to mac.CC"
            @mac.setCC value
          else
            targetError = true
      else
        targetError = true
    return not targetError
    
  performCompute: (target) ->
    switch target
      when "ram"
        @log.debug -> "running ram"
        @ram.compute()
      when "alu"
        @log.debug -> "running alu"
        @alu.compute()
      when "mac"
        @log.debug -> "running mac"
        @mac.compute()
      else
        @log.error -> "unknown compute target: #{target}"

  setNextPhase: ->
    @nextPhase = (@nextPhase + 1) % 3
    @notifyNextPhase(@nextPhase)

  notifySignal: (to, from) ->
    listener.onSignal?(to, from) for listener in @cpuListeners

  notifyNextPhase: (phase) ->
    listener.onNextPhase?(phase) for listener in @cpuListeners

  notifySetRegister: (register, value) ->
    listener.onSetRegister?(register, value) for listener in @cpuListeners

  notifyMicrocode: (mc) ->
    listener.onSetMicrocode?(mc) for listener in @cpuListeners

  # resets alu and mac
  reset: ->
    @alu.reset()
    @mac.reset()
    @ram.reset()
    @rom.reset()
    for register in [0..7]
      @setRegister register, (Utils.randomBitSequence 32)
    @setMicrocode (@rom.getMicrocode 0)
