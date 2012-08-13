class @AluController extends AbstractController
  constructor: (@alu) ->
    @log = Utils.getLogger 'AluController'
    @initListener()
    @setButtonHandlers()

  initListener: ->
    @aluListener = new AluListener()
    @aluListener.setOnSetX (value) =>
      ($ "#alu-x-tf").val (Utils.decToHex value, 8)
    @aluListener.setOnSetY (value) ->
      ($ "#alu-y-tf").val (Utils.decToHex value, 8)
    @aluListener.setOnSetZ (value) ->
      ($ "#alu-z-tf").val (Utils.decToHex value, 8)
    @aluListener.setOnSetCC (value) ->
      ($ "#cc-cc-tf").val (Utils.decToBin value, 4)
    @aluListener.setOnSetFlags (value) ->
      ($ "#alu-cc-tf").val (Utils.decToBin value, 4)
    @aluListener.setOnSetFC (value) ->
      ($ "#alu-fc-label").html (Utils.functionCodeToText value)

    @log.debug -> "setting alu listener"
    @alu.setAluListeners [@aluListener]

  setButtonHandlers: ->
    ($ "#alu-x-btn").click =>
      @showSetValueModal @alu.getXRegister(), 0xFFFFFFFF, 32, (val) =>
        @alu.setXRegister val
    ($ "#alu-y-btn").click =>
      @showSetValueModal @alu.getYRegister(), 0xFFFFFFFF, 32, (val) =>
        @alu.setYRegister val
    ($ "#alu-z-btn").click =>
      @showSetValueModal @alu.getZRegister(), 0xFFFFFFFF, 32, (val) =>
        @alu.setZRegister val
    ($ "#alu-cc-btn").click =>
      @showSetValueModal @alu.getCCFlags(), 0xF, 4, (val) =>
        @alu.setCCFlags val
    ($ "#cc-cc-btn").click =>
      @showSetValueModal @alu.getCCRegister(), 0xF, 4, (val) =>
        @alu.setCCRegister val

  setHighlightXRegister: (mode) ->
    if mode is on
      @highlightElement "#alu-x-pv"
    else
      @unhighlightElement "#alu-x-pv"

  setHighlightYRegister: (mode) ->
    if mode is on
      @highlightElement "#alu-y-pv"
    else
      @unhighlightElement "#alu-y-pv"

  setHighlightZRegister: (mode) ->
    if mode is on
      @highlightElement "#alu-z-pv"
    else
      @unhighlightElement "#alu-z-pv"

  setHighlightCCFlags: (mode) ->
    if mode is on
      @highlightElement "#alu-cc-pv"
    else
      @unhighlightElement "#alu-cc-pv"

  setHighlightCCRegister: (mode) ->
    if mode is on
      @highlightElement "#cc-cc-pv"
    else
      @unhighlightElement "#cc-cc-pv" 