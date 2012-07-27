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
      # 2: X->Z
      when 2
        @setZRegister(@xRegister)
        @updateCCFlagsSInt()
      # 4: Y->Z
      when 4
        @setZRegister(@yRegister)
        @updateCCFlagsSInt()
      # 6: Z->Y, X<->Y
      when 6
        originalXvalue = @xRegister
        @setZRegister(@yRegister)
        @setXRegister(@yRegister)
        @setYRegister(originalXvalue)
        @updateCCFlagsSInt()
      # 8: Y->Z, Y->X
      when 8
        @setXRegister(@yRegister)
        @setZRegister(@yRegister)
        @updateCCFlagsSInt()
      # 9: X+1->Z
      when 9
        @setZRegister(((@xRegister+1) & 0xFFFFFFFF) >>> 0)
        @updateCCFlagsSInt()
        @setCCFlags(Utils.setBit(@ccFlags, 1)) if @zRegister is 0x80000000
      # 10: X-1->Z
      when 10
        @setZRegister(((@xRegister-1) & 0xFFFFFFFF) >>> 0)
        @updateCCFlagsSInt()
        @setCCFlags(Utils.setBit(@ccFlags, 1)) if @zRegister is 0x7FFFFFFF

  updateCCFlagsSInt: ->
    if @zRegister is 0
        @setCCFlags(8)
    else
        if Utils.isBitSet(@zRegister, 32) is on
          @setCCFlags(2)
        else
          @setCCFlags(4)

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
