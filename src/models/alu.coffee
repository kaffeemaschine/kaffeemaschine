class @Alu
  constructor: (@aluListeners = []) ->
      @xRegister = 0
      @yRegister = 0
      @zRegister = 0
      @ccRegister = 0
      @ccFlags = 0
      @functionCode = 0

  setAluListeners: (l) -> @aluListeners = l
  
  getXRegister: -> @xRegister
  getYRegister: -> @yRegister
  getZRegister: -> @zRegister
  getCCRegister: -> @ccRegister
  getCCFlags: -> @ccFlags
  getFunctionCode: -> @functionCode
  getState: ->
      x: @xRegister
      y: @yRegister
      z: @zRegister
      cc: @ccRegister
      ccFlags: @ccFlags
      fCode: @functionCode
  
  setXRegister: (val) ->
    @xRegister = val
    @notifyX(@xRegister)
  setYRegister: (val) ->
    @yRegister = val
    @notifyY(@yRegister)
  setZRegister: (val) ->
    @zRegister = val
    @notifyZ(@zRegister)
  setCCRegister: (val) ->
    @ccRegister = val
    @notifyCC(@ccRegister)
  setCCFlags: (val) ->
    @ccFlags = val
    @notifyFlags(@ccFlags)
  setFunctionCode: (val) ->
    @functionCode = val
    @notifyFC(@functionCode)
  
  compute: ->
      

  notifyX: (x) ->
    listener.onSetX?(x) for listener in @aluListeners

  notifyY: (x) ->
    listener.onSetY?(x) for listener in @aluListeners

  notifyZ: (x) ->
    listener.onSetZ?(x) for listener in @aluListeners

  notifyCC: (x) ->
    listener.onSetCC?(x) for listener in @aluListeners

  notifyFlags: (x) ->
    listener.onSetFlags?(x) for listener in @aluListeners

  notifyFC: (x) ->
    listener.onSetFC?(x) for listener in @aluListeners