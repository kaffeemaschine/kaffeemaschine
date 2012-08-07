class @CpuController
  constructor: ->
    @log = Utils.getLogger 'CpuController'

    @nextPhase = 0
    
    # reset button
    ($ "#power-reset-btn").click =>
      @cpu.reset()

    #microcode-xbus
    # for now... needs better solution for event handling
    ($ "#microcode-xbus-tf").keyup =>
      val = parseInt ($ "#microcode-xbus-tf").val(), 2
      val = (val & 0xFF) >>> 0
      mc = @cpu.microcode
      mc.xbus = val
      @cpu.setMicrocode(mc)
      @preview()

    # init cpu listener
    @log.debug -> "init cpu listener"
    @cpuListener = new CpuListener()
    @cpuListener.setOnSetRegister( (register, value) ->
      ($ "#registers-r#{register}-tf").val(Utils.decToHex(value, 8)))
    @cpuListener.setOnSetMicrocode( (mc) ->
      ($ "#microcode-mode-tf").val(Utils.decToBin(mc.mode, 2))
      ($ "#microcode-mcnext-tf").val(Utils.decToBin(mc.mcnext, 6))
      ($ "#microcode-alufc-tf").val(Utils.decToBin(mc.alufc, 8))
      ($ "#microcode-xbus-tf").val(Utils.decToBin(mc.xbus, 8))
      ($ "#microcode-ybus-tf").val(Utils.decToBin(mc.ybus, 8))
      ($ "#microcode-zbus-tf").val(Utils.decToBin(mc.zbus, 8))
      ($ "#microcode-ioswitch-tf").val(Utils.decToBin(mc.ioswitch, 8))
      ($ "#microcode-byte-tf").val(Utils.decToBin(mc.byte, 2))
      ($ "#info-tarea").val(mc.remarks))

    # init cpu
    @log.debug -> "init cpu"
    @cpu = new Cpu()
    @cpu.setCpuListeners [@cpuListener]
    @cpu.reset()
    @preview()

  clearPreview: ->
    @unhighlighElement "#rom-mcar-pv"
    @unhighlighElement "#mac-mcn-pv"
    @unhighlighElement "#mac-mcar-pv"
    @unhighlighElement "#mac-nextmc-pv"
    @unhighlighElement "#mac-mcop-pv"
    @unhighlighElement "#mac-mask-pv"
    @unhighlighElement "#mac-cc-pv"
    @unhighlighElement "#ram-mar-pv"
    @unhighlighElement "#ramc-mdr-pv"
    for register in [0..7]
      @unhighlighElement "#registers-r#{register}-pv"
    @unhighlighElement "#alu-x-pv"
    @unhighlighElement "#alu-y-pv"
    @unhighlighElement "#alu-z-pv"
    @unhighlighElement "#alu-cc-pv"
    @unhighlighElement "#cc-cc-pv"

  preview: ->
    @clearPreview()
    switch @nextPhase
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
      else
        @log.error -> "unknown command: #{action}"
        

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
            @highlightElement "#alu-z-pv"
          when "CC"
            @log.debug -> "adding alu-cc-pv"
            @highlightElement "#alu-cc-pv"
    
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
            @highlightElement "#alu-x-pv"
          when "Y"
            @log.debug -> "to alu.Y"
            @highlightElement "#alu-y-pv"
          when "Z"
            @log.debug -> "to alu.Z"
            @highlightElement "#alu-z-pv"
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

  highlightElement: (id) ->
    unless $("id").hasClass("success")
              $("id").addClass("success")

  unhighlighElement: (id) ->
    $("id").removeClass("success")

  setNextPhase: ->
    @nextPhase = (@nextPhase + 1) % 3

$(document).ready -> new CpuController()