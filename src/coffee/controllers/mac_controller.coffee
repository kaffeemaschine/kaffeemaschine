class @MacController extends AbstractController
  constructor: (@mac) ->
    @log = Utils.getLogger 'MacController'
    @initListener()
    @initButtonHandlers()


  initListener: ->
    @macListener = new MacListener()
    @macListener.setOnSetMode (mode) ->
      switch mode
        when 0
          text = '4 &times; MCN'
        when 1
          text = 'MCAR + 1 + 4 &times; MCN'
        when 2
          text = 'MCAR + 1 - 4 &times; MCN'
        when 3
          text = '4 &times; MCOP abs./cond.'
      ($ '#mac-jumpmode-label').html text
    @macListener.setOnSetCC (cc) ->
      ($ '#mac-cc-tf').val (Utils.decToBin cc, 4)
    @macListener.setOnSetMask (mask) ->
      ($ '#mac-mask-tf').val (Utils.decToBin mask, 4)
    @macListener.setOnSetTimes4 (t) ->
      switch t
        when 0
          text = '0 &times;'
        when 1
          text = '4 &times;'
      ($ '#mac-condition-badge').html text
    @macListener.setOnSetMcop (mcop) ->
      ($ '#mac-mcop-tf').val (Utils.decToHex mcop, 2)
    @macListener.setOnSetMcarNext (mcnext) ->
      ($ '#mac-nextmc-tf').val (Utils.decToHex mcnext, 3)
    @macListener.setOnSetMcn (mcn) ->
      ($ '#mac-mcn-tf').val (Utils.decToBin mcn, 6)
    @macListener.setOnSetMcar (mcar) ->
      ($ '#mac-mcar-tf').val (Utils.decToHex mcar, 3)

    @log.debug -> 'setting mac listener'
    @mac.setMacListeners [@macListener]

  initButtonHandlers: ->
    ($ '#mac-mcn-btn').click =>
      @showSetValueModal @mac.mcnRegister, 0x3F, 6, (val) =>
        @mac.setMcn val
    ($ '#mac-mcar-btn').click =>
      @showSetValueModal @mac.mcarRegister, 0xFFF, 12, (val) =>
        @mac.setMcar val
    ($ '#mac-nextmc-btn').click =>
      @showSetValueModal @mac.mcarNextRegister, 0xFFF, 12, (val) =>
        @mac.setMcarNext val
    ($ '#mac-mcop-btn').click =>
      @showSetValueModal @mac.mcopRegister, 0xFF, 8, (val) =>
        @mac.setMcop val
    ($ '#mac-mask-btn').click =>
      @showSetValueModal @mac.maskRegister, 0xF, 4, (val) =>
        @mac.setMask val
    ($ '#mac-cc-btn').click =>
      @showSetValueModal @mac.ccRegister, 0xF, 4, (val) =>
        @mac.setCC val

  