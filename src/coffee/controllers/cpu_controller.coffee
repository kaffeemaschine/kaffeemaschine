class @CpuController extends AbstractController
  constructor: ->
    @log = Utils.getLogger 'CpuController'

    # conductors
    @cpv = new ConductorPathView()

    alu = new Alu()
    ram = new Ram()
    mac = new Mac()
    rom = new Rom()
    @cpu = new Cpu(alu, ram, mac, rom)
    
    @aluController = new AluController(alu)

    @initListener()
    @cpu.setCpuListeners [@cpuListener]

    @setPowerHandlers()
    @setMicrocodeInputHandlers()
    @setMicrocodeButtonHandlers()
    @setRegistersButtonHandlers()

    @cpu.reset()
    @preview()

  initListener: ->
    @log.debug -> "init cpu listener"
    @cpuListener = new CpuListener()
    @cpuListener.setOnSetRegister (register, value) ->
      ($ "#registers-r#{register}-tf").val(Utils.decToHex(value, 8))
    @cpuListener.setOnSetMicrocode (mc) =>
      ($ "#microcode-mode-tf").val(Utils.decToBin(mc.mode, 2))
      ($ "#microcode-mcnext-tf").val(Utils.decToBin(mc.mcnext, 6))
      ($ "#microcode-alufc-tf").val(Utils.decToBin(mc.alufc, 7))
      ($ "#microcode-xbus-tf").val(Utils.decToBin(mc.xbus, 8))
      ($ "#microcode-ybus-tf").val(Utils.decToBin(mc.ybus, 8))
      ($ "#microcode-zbus-tf").val(Utils.decToBin(mc.zbus, 8))
      ($ "#microcode-ioswitch-tf").val(Utils.decToBin(mc.ioswitch, 8))
      ($ "#microcode-byte-tf").val(Utils.decToBin(mc.byte, 2))
      ($ "#info-tarea").val(mc.remarks)
      @preview()
    @cpuListener.setOnNextPhase (phase) =>
      @cpv.redraw()
      @preview()
      @cpv.resetActive()
    @cpuListener.setOnSignal (to, from) =>
      [domain, register] = from.split "."
      switch to
        when "alu.X"
          @cpv.setActiveX (parseInt register), true
        when "alu.Y"
          switch domain
            when "registers"
              @cpv.setActiveY (parseInt register), true
            when "ram"
              @cpv.setActiveY 8, true

  setPowerHandlers: ->
    # reset button
    ($ "#power-reset-btn").click =>
      @cpu.reset()
      @cpv.resetActive()
    # run phase button
    ($ "#power-phase-btn").click =>
      @cpu.runPhase()
    # run tact button
    ($ "#power-tact-btn").click =>
      @cpu.runTact()

  setMicrocodeInputHandlers: ->
    @mkInputHandler "#microcode-mode-tf", 2, 0x3, (value) =>
      @cpu.setMicrocodeField("mode", value)
    @mkInputHandler "#microcode-mcnext-tf", 2, 0x3F, (value) =>
      @cpu.setMicrocodeField("mcnext", value)
    @mkInputHandler "#microcode-alufc-tf", 2, 0x7F, (value) =>
      @cpu.setMicrocodeField("alufc", value)
    @mkInputHandler "#microcode-xbus-tf", 2, 0xFF, (value) =>
      @cpu.setMicrocodeField("xbus", value)
    @mkInputHandler "#microcode-ybus-tf", 2, 0xFF, (value) =>
      @cpu.setMicrocodeField("ybus", value)
    @mkInputHandler "#microcode-zbus-tf", 2, 0xFF, (value) =>
      @cpu.setMicrocodeField("zbus", value)
    @mkInputHandler "#microcode-ioswitch-tf", 2, 0xFF, (value) =>
      @cpu.setMicrocodeField("ioswitch", value)
    @mkInputHandler "#microcode-byte-tf", 2, 0x3, (value) =>
      @cpu.setMicrocodeField("byte", value)

  setMicrocodeButtonHandlers: ->
    ($ "#microcode-mode-btn").click =>
      @showSetValueModal @cpu.microcode.mode, 0x3, 2, (val) =>
        @cpu.setMicrocodeField "mode", val
    ($ "#microcode-mcnext-btn").click =>
      @showSetValueModal @cpu.microcode.mcnext, 0x3F, 6, (val) =>
        @cpu.setMicrocodeField "mcnext", val
    ($ "#microcode-alufc-btn").click =>
      @showSetValueModal @cpu.microcode.alufc, 0x7F, 7, (val) =>
        @cpu.setMicrocodeField "alufc", val
    ($ "#microcode-xbus-btn").click =>
      @showSetValueModal @cpu.microcode.xbus, 0xFF, 8, (val) =>
        @cpu.setMicrocodeField "xbus", val
    ($ "#microcode-ybus-btn").click =>
      @showSetValueModal @cpu.microcode.ybus, 0xFF, 8, (val) =>
        @cpu.setMicrocodeField "ybus", val
    ($ "#microcode-zbus-btn").click =>
      @showSetValueModal @cpu.microcode.zbus, 0xFF, 8, (val) =>
        @cpu.setMicrocodeField "zbus", val
    ($ "#microcode-ioswitch-btn").click =>
      @showSetValueModal @cpu.microcode.ioswitch, 0xFF, 8, (val) =>
        @cpu.setMicrocodeField "ioswitch", val
    ($ "#microcode-byte-btn").click =>
      @showSetValueModal @cpu.microcode.byte, 0x3, 2, (val) =>
        @cpu.setMicrocodeField "byte", val

  setRegistersButtonHandlers: ->
    bind = (register) =>
      ($ "#registers-r#{register}-btn").click =>
        @showSetValueModal @cpu.registers[register], 0xFFFFFFFF, 32, (val) =>
          @cpu.setRegister register, val
    for register in [0..7]
      bind register

  clearPreview: ->
    @unhighlightElement "#rom-mcar-pv"
    @unhighlightElement "#mac-mcn-pv"
    @unhighlightElement "#mac-mcar-pv"
    @unhighlightElement "#mac-nextmc-pv"
    @unhighlightElement "#mac-mcop-pv"
    @unhighlightElement "#mac-mask-pv"
    @unhighlightElement "#mac-cc-pv"
    @unhighlightElement "#ram-mar-pv"
    @unhighlightElement "#ram-mdr-pv"
    for register in [0..7]
      @unhighlightElement "#registers-r#{register}-pv"
    @aluController.setHighlightXRegister off
    @aluController.setHighlightYRegister off
    @aluController.setHighlightZRegister off
    @aluController.setHighlightCCFlags off
    @aluController.setHighlightCCRegister off

  preview: ->
    @clearPreview()
    switch @cpu.nextPhase
      when 0 then actions = MicrocodeParser.parseGetPhase @cpu.microcode
      when 1 then actions = MicrocodeParser.parseCalcPhase @cpu.microcode
      when 2 then actions = MicrocodeParser.parsePutPhase @cpu.microcode
    @previewAction action for action in actions

  previewAction: (a) ->
    @log.debug -> "previewing action=#{a}"
    [action, rest...] = a.split " "

    switch action
      when "compute"
        @log.debug -> "preview compute..."
        [target] = rest
        @previewCompute target
      when "push"
        @log.debug -> "preview push..."
        [to, from] = rest
        @previewPush to, from
      when "pushval"
        @log.debug -> "preview pushval..."
        [to, value] = rest
        @previewPushVal to, value
      when "next"
        @log.debug -> "preview fetching next microcode"
      when "info"
        @log.debug -> "preview info..."
        [ac, value] = rest
        @previewInfo ac, value
      else
        @log.error -> "unknown command: #{action}"
        
  previewInfo: (action, val) ->
    switch action
      when "update"
        switch val
          when "cc"
            @log.debug -> "preview update cc"
            @aluController.setHighlightCCRegister on
          else
            @log.error -> "unknown update target: #{val}"
      else
        @log.error -> "unknown info action: #{action}"


  previewPush: (to, from) ->
    [fromDomain, fromRegister] = from.split "."
    switch fromDomain
      when "registers"
        @log.debug -> "adding registers-r#{fromRegister}-pv"
        @highlightElement "#registers-r#{fromRegister}-pv"
      when "ram"
        switch fromRegister
          when "MAR"
            @log.debug -> "adding ram-mar-pv"
            @highlightElement "#ram-mar-pv"
          when "MDR"
            @log.debug -> "adding ram-mdr-pv"
            @highlightElement "#ram-mdr-pv"
      when "rom"
        switch fromRegister
          when "MCAR"
            @log.debug -> "adding rom-mcar-pv"
            @highlightElement "#rom-mcar-pv"
      when "mac"
        switch fromRegister
          when "MCARNEXT"
            @log.debug -> "adding mac-nextmcar-pv"
            @highlightElement "#mac-nextmcar-pv"
      when "alu"
        switch fromRegister
          when "Z"
            @log.debug -> "adding alu-z-pv"
            @aluController.setHighlightZRegister on
          when "CC"
            @log.debug -> "adding alu-cc-pv"
            @aluController.setHighlightCCFlags on
    
    if @previewSetTarget(to) is true
      @log.debug -> "...push ok"
    else
      @log.error -> "unknown push target: #{to}"
      @log.debug -> "...push failed"

  previewPushVal: (to) ->
    if @previewSetTarget(to) is true
      @log.debug -> "...pushval ok"
    else
      @log.error -> "unknown pushval target: #{to}"
      @log.debug -> "...pushval failed"

  previewSetTarget: (target) ->
    [toDomain, toRegister] = target.split "."
    targetError = false
    switch toDomain
      when "registers"
        @log.debug => "to R#{parseInt toRegister}"
        @highlightElement "#registers-r#{toRegister}-pv"
      when "ram"
        switch toRegister
          when "MAR"
            @log.debug -> "to ram.MAR"
            @highlightElement "#ram-mar-pv"
          when "MDR"
            @log.debug -> "to ram.MDR"
            @highlightElement "#ram-mdr-pv"
          else
            targetError = true
      when "rom"
        switch toRegister
          when "MCAR"
            @log.debug -> "to rom.MCAR"
            @highlightElement "#rom-mcar-pv"
          else
            targetError = true
      when "alu"
        switch toRegister
          when "X"
            @log.debug -> "to alu.X"
            @aluController.setHighlightXRegister on
          when "Y"
            @log.debug -> "to alu.Y"
            @aluController.setHighlightYRegister on
          when "Z"
            @log.debug -> "to alu.Z"
            @aluController.setHighlightZRegister on
          when "FC"
            @log.debug -> "to alu.FC"

          else
            targetError = true
      when "mac"
        switch toRegister
          when "MCOP"
            @log.debug -> "to mac.MCOP"
            @highlightElement "#mac-mcop-pv"
          when "MCAR"
            @log.debug -> "to mac.MCAR"
            @highlightElement "#mac-mcar-pv"
          when "mode"
            @log.debug -> "to mac.mode"

          when "MCN"
            @log.debug -> "to mac.MCN"
            @highlightElement "#mac-mcn-pv"
          when "MASK"
            @log.debug -> "to mac.MASK"
            @highlightElement "#mac-mask-pv"
          when "CC"
            @log.debug => "to mac.CC"
            @highlightElement "#mac-cc-pv"
          else
            targetError = true
      else
        targetError = true
    return not targetError
    
  previewCompute: (target) ->
    switch target
      when "ram"
        @log.debug -> "preview running ram"
      when "alu"
        @log.debug -> "preview running alu"
      when "mac"
        @log.debug -> "preview running mac"
      else
        @log.error -> "unknown compute target: #{target}"
