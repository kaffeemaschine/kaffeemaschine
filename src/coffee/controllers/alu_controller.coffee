class @AluController extends AbstractController
  constructor: (@alu) ->
    @log = Utils.getLogger 'AluController'
    @initListener()

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