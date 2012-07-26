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
    switch @functionCode
      # 0: NOP
      when 0 then return
      # 1: X<->Y
      when 1
        tmp = @xRegister
        @setXRegister(@yRegister)
        @setYRegister(tmp)
      # 2: Z=Z, X->Y, X=0
      when 2
        @setYRegister(@xRegister)
        @setXRegister(0)
      # 3: Z=Z, Y->X, Y=0
      when 3
        @setXRegister(@yRegister)
        @setYRegister(0)
      # 4: Z=X
      when 4
        @setZRegister(@xRegister)
        @updateCCFlagsSInt()
      # 5: Z=Y
      when 5
        @setZRegister(@yRegister)
        @updateCCFlagsSInt()

  updateCCFlagsSInt: ->
    @setCCFlags(0x8) if @zRegister is 0
    @setCCFlags(0x4) if @zRegister isnt 0 and Utils.isBitSet(@zRegister, 32) is off
    @setCCFlags(0x2) if @zRegister isnt 0 and Utils.isBitSet(@zRegister, 32) is on
    

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