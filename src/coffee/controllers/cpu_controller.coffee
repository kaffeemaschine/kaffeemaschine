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
    $("#rom-mcar-pv").removeClass("success")
    $("#mac-mcn-pv").removeClass("success")
    $("#mac-mcar-pv").removeClass("success")
    $("#mac-nextmc-pv").removeClass("success")
    $("#mac-mcop-pv").removeClass("success")
    $("#mac-mask-pv").removeClass("success")
    $("#mac-cc-pv").removeClass("success")
    $("#ram-mar-pv").removeClass("success")
    $("#ramc-mdr-pv").removeClass("success")
    for register in [0..7]
      $("#registers-r#{register}-pv").removeClass("success")
    $("#alu-x-pv").removeClass("success")
    $("#alu-y-pv").removeClass("success")
    $("#alu-z-pv").removeClass("success")
    $("#alu-cc-pv").removeClass("success")
    $("#cc-cc-pv").removeClass("success")

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
        unless $("#registers-r#{fromRegister}-pv").hasClass("success")
          $("#registers-r#{fromRegister}-pv").addClass("success")
      when "ram"
        switch fromRegister
          when "MAR"
            @log.debug -> "adding ram-mar-pv"
            unless $("#ram-mar-pv").hasClass("success")
              $("#ram-mar-pv").addClass("success")
          when "MDR"
            @log.debug -> "adding ram-mdr-pv"
            unless $("#ram-mdr-pv").hasClass("success")
              $("#ram-mdr-pv").addClass("success")
      when "rom"
        switch fromRegister
          when "MCAR"
            @log.debug -> "adding rom-mcar-pv"
            unless $("#rom-mcar-pv").hasClass("success")
              $("#rom-mcar-pv").addClass("success")
      when "mac"
        switch fromRegister
          when "MCARNEXT"
            @log.debug -> "adding mac-nextmcar-pv"
            unless $("#mac-nextmcar-pv").hasClass("success")
              $("#mac-nextmcar-pv").addClass("success")
      when "alu"
        switch fromRegister
          when "Z"
            @log.debug -> "adding alu-z-pv"
            unless $("#alu-z-pv").hasClass("success")
              $("#alu-z-pv").addClass("success")
          when "CC"
            @log.debug -> "adding alu-cc-pv"
            unless $("#alu-cc-pv").hasClass("success")
              $("#alu-cc-pv").addClass("success")
    
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
        unless $("#registers-r#{toRegister}-pv").hasClass("success")
          $("#registers-r#{toRegister}-pv").addClass("success")
      when "ram"
        switch toRegister
          when "MAR"
            @log.debug -> "to ram.MAR"
            unless $("#ram-mar-pv").hasClass("success")
              $("#ram-mar-pv").addClass("success")
          when "MDR"
            @log.debug -> "to ram.MDR"
            unless $("#ram-mdr-pv").hasClass("success")
              $("#ram-mdr-pv").addClass("success")
          else
            targetError = true
      when "rom"
        switch toRegister
          when "MCAR"
            @log.debug -> "to rom.MCAR"
            unless $("#rom-mcar-pv").hasClass("success")
              $("#rom-mcar-pv").addClass("success")
          else
            targetError = true
      when "alu"
        switch toRegister
          when "X"
            @log.debug -> "to alu.X"
            unless $("#alu-x-pv").hasClass("success")
              $("#alu-x-pv").addClass("success")
          when "Y"
            @log.debug -> "to alu.Y"
            unless $("#alu-y-pv").hasClass("success")
              $("#alu-y-pv").addClass("success")
          when "Z"
            @log.debug -> "to alu.Z"
            unless $("#alu-z-pv").hasClass("success")
              $("#alu-z-pv").addClass("success")
          when "FC"
            @log.debug -> "to alu.FC"

          else
            targetError = true
      when "mac"
        switch toRegister
          when "MCOP"
            @log.debug -> "to mac.MCOP"
            unless $("#mac-mcop-pv").hasClass("success")
              $("#mac-mcop-pv").addClass("success")
          when "MCAR"
            @log.debug -> "to mac.MCAR"
            unless $("#mac-mcar-pv").hasClass("success")
              $("#mac-mcar-pv").addClass("success")
          when "mode"
            @log.debug -> "to mac.mode"

          when "MCN"
            @log.debug -> "to mac.MCN"
            unless $("#mac-mcn-pv").hasClass("success")
              $("#mac-mcn-pv").addClass("success")
          when "MASK"
            @log.debug -> "to mac.MASK"
            unless $("#mac-mask-pv").hasClass("success")
              $("#mac-mask-pv").addClass("success")
          when "CC"
            @log.debug => "to mac.CC"
            unless $("#mac-cc-pv").hasClass("success")
              $("#mac-cc-pv").addClass("success")
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

  setNextPhase: ->
    @nextPhase = (@nextPhase + 1) % 3

$(document).ready -> new CpuController()