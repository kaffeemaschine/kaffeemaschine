class @Alu
  constructor: (@aluListeners = []) ->
    @log = Utils.getLogger "Alu"
    @log.debug -> "constructor start"
    @log.debug -> "creating Alu"
    @reset()
    @log.debug -> "constructor done"

  setAluListeners: (l) ->
    @log.debug -> "setting alu listeners to #{l}"
    @aluListeners = l

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
    val = Utils.sanitizeNum val, 0xFFFFFFFF
    @xRegister = val
    @notifyX(@xRegister)
  setYRegister: (val) ->
    val = Utils.sanitizeNum val, 0xFFFFFFFF
    @yRegister = val
    @notifyY(@yRegister)
  setZRegister: (val) ->
    val = Utils.sanitizeNum val, 0xFFFFFFFF
    @zRegister = val
    @notifyZ(@zRegister)
  setCCRegister: (val) ->
    val = Utils.sanitizeNum val, 0xF
    @ccRegister = val
    @notifyCC(@ccRegister)
  setCCFlags: (val) ->
    val = Utils.sanitizeNum val, 0xF
    @ccFlags = val
    @notifyFlags(@ccFlags)
  setFunctionCode: (val) ->
    val = Utils.sanitizeNum val, 0x7F
    @functionCode = val
    @notifyFC(@functionCode)

  compute: ->
    @log.debug => "computing functionCode=#{@functionCode}"
    copyCC = Utils.isBitSet(@functionCode, 7)

    if Utils.isBitSet(@functionCode, 7)
      fc = Utils.unsetBit(@functionCode, 7)
    else
      fc = @functionCode

    @log.debug => "fc is functionCode=#{fc}"
    switch fc
      # 0: NOP
      # 1: -Z->Z
      when 1
        z = if Utils.isNegative(@zRegister) then @zRegister<<0 else @zRegister
        @setZRegister((-z & 0xFFFFFFFF) >>> 0) # >>> to get unsigned value
        @updateCCFlags()
      # 2: X->Z
      when 2
        @setZRegister(@xRegister)
        @updateCCFlags()
      # 3: -X->Z
      when 3
        x = if Utils.isNegative(@xRegister) then @xRegister<<0 else @xRegister
        @setZRegister((-x & 0xFFFFFFFF) >>> 0) # >>> to get unsigned value
        @updateCCFlags()
      # 4: Y->Z
      when 4
        @setZRegister(@yRegister)
        @updateCCFlags()
      # 5: -Y->Z
      when 5
        y = if Utils.isNegative(@yxRegister) then @yRegister<<0 else @yRegister
        @setZRegister((-y & 0xFFFFFFFF) >>> 0) # >>> to get unsigned value
        @updateCCFlags()
      # 6: Y->Z, X<->Y
      when 6
        originalXvalue = @xRegister
        @setZRegister(@yRegister)
        @setXRegister(@yRegister)
        @setYRegister(originalXvalue)
        @updateCCFlags()
      # 7: X->Z, X<->Y
      when 7
        originalXvalue = @xRegister
        @setZRegister(@xRegister)
        @setXRegister(@yRegister)
        @setYRegister(originalXvalue)
        @updateCCFlags()
      # 8: Y->Z, Y->X
      when 8
        @setXRegister(@yRegister)
        @setZRegister(@yRegister)
        @updateCCFlags()
      # 9: X+1->Z
      when 9
        if @xRegister is 0x7FFFFFFF
          @setZRegister 0x80000000
          @setCCFlags(0x5) # positive + overflow
        else
          # no overflow
          x = if Utils.isNegative(@xRegister) then @xRegister<<0 else @xRegister
          @setZRegister(((x+1) & 0xFFFFFFFF) >>> 0) # >>> to get unsigned value
          @updateCCFlags()
      # 10: X-1->Z
      when 10
        if @xRegister is 0x80000000
          @setZRegister 0x7FFFFFFF
          @setCCFlags(0x3) # negative + overflow
        else
          # no overflow
          x = if Utils.isNegative(@xRegister) then @xRegister<<0 else @xRegister
          @setZRegister(((x-1) & 0xFFFFFFFF) >>> 0) # >>> to get unsigned value
          @updateCCFlags()
      # 11: X+Y->Z
      when 11
        @log.debug => "adding"
        x = if Utils.isNegative(@xRegister) then @xRegister<<0 else @xRegister
        y = if Utils.isNegative(@yRegister) then @yRegister<<0 else @yRegister
        @setZRegister(((x+y) & 0xFFFFFFFF) >>> 0) # >>> to get unsigned value
        if x+y > 0x7FFFFFFF
          # overflow
          @setCCFlags(0x5) # positive + overflow
        else if x+y < (0x80000000<<0)
          # underflow
          @setCCFlags(0x3) # negative + overflow
        else
          # no overflow
          @updateCCFlags()
      # 12: X-Y->Z
      when 12
        x = if Utils.isNegative(@xRegister) then @xRegister<<0 else @xRegister
        y = if Utils.isNegative(@yRegister) then @yRegister<<0 else @yRegister
        @setZRegister(((x-y) & 0xFFFFFFFF) >>> 0) # >>> to get unsigned value
        if x-y > 0x7FFFFFFF
          # overflow
          @setCCFlags(0x5) # positive + overflow
        else if x-y < (0x80000000<<0)
          # underflow
          @setCCFlags(0x3) # negative + overflow
        else
          # no overflow
          @updateCCFlags()
      # 13: X*Y->Z
      when 13
        x = if Utils.isNegative(@xRegister) then @xRegister<<0 else @xRegister
        y = if Utils.isNegative(@yRegister) then @yRegister<<0 else @yRegister
        @setZRegister(((x*y) & 0xFFFFFFFF) >>> 0) # >>> to get unsigned value
        if x*y > 0x7FFFFFFF
          # overflow
          @setCCFlags(0x5) # positive + overflow
        else if x*y < (0x80000000<<0)
          # underflow
          @setCCFlags(0x3) # negative + overflow
        else
          # no overflow
          @updateCCFlags()
      # 14: X/Y->Z
      when 14
        x = if Utils.isNegative(@xRegister) then @xRegister<<0 else @xRegister
        y = if Utils.isNegative(@yRegister) then @yRegister<<0 else @yRegister
        if y is 0
          @setCCFlags(Utils.setBit(@ccFlags, 1))
        else
          # use >>> to get unsigned value
          @setZRegister(((Math.floor(x/y)) & 0xFFFFFFFF) >>> 0)
          @updateCCFlags()
      # 15: X%Y->Z
      when 15
        x = if Utils.isNegative(@xRegister) then @xRegister<<0 else @xRegister
        y = if Utils.isNegative(@yRegister) then @yRegister<<0 else @yRegister
        if y is 0
          @setCCFlags(Utils.setBit(@ccFlags, 1))
        else
          @setZRegister(((x%y) & 0xFFFFFFFF) >>> 0) # >>> to get unsigned value
          @updateCCFlags()
      # 16: X SAL Y->Z
      when 16
        y = if Utils.isNegative(@yRegister) then @yRegister<<0 else @yRegister
        # use >>> to get unsigned value
        @setZRegister(((@xRegister<<(y%32)) & 0xFFFFFFFF) >>> 0)
        @updateCCFlags()
      # 17: X SAR Y->Z
      when 17
        y = if Utils.isNegative(@yRegister) then @yRegister<<0 else @yRegister
        # use >>> to get unsigned value
        @setZRegister(((@xRegister>>>(y%32)) & 0xFFFFFFFF) >>> 0)
        @updateCCFlags()
      # 18: CMP arithm. X Y->Z // !refactor or keep in sync with FC#12!
      when 18
        x = if Utils.isNegative(@xRegister) then @xRegister<<0 else @xRegister
        y = if Utils.isNegative(@yRegister) then @yRegister<<0 else @yRegister
        @setZRegister(((x-y) & 0xFFFFFFFF) >>> 0) # >>> to get unsigned value
        if x-y > 0x7FFFFFFF
          # overflow
          @setCCFlags(0x5) # positive + overflow
        else if x-y < (0x80000000<<0)
          # underflow
          @setCCFlags(0x3) # negative + overflow
        else
          # no overflow
          @updateCCFlags()
      # 19: X AND Y -> Z
      when 19
        @setZRegister((@xRegister & @yRegister) >>> 0)
        @updateCCFlags()
      # 20: X NAND Y -> Z
      when 20
        @setZRegister(((@xRegister & @yRegister) ^ 0xFFFFFFFF) >>> 0)
        @updateCCFlags()
      # 21: X OR Y -> Z
      when 21
        @setZRegister((@xRegister | @yRegister) >>> 0)
        @updateCCFlags()
      # 22: X NOR Y -> Z
      when 22
        @setZRegister(((@xRegister | @yRegister) ^ 0xFFFFFFFF) >>> 0)
        @updateCCFlags()
      # 23: X XOR Y -> Z
      when 23
        @setZRegister((@xRegister ^ @yRegister) >>> 0)
        @updateCCFlags()
      # 24: X NXOR Y -> Z
      when 24
        @setZRegister(((@xRegister ^ @yRegister) ^ 0xFFFFFFFF) >>> 0)
        @updateCCFlags()
      # 25: X SLL Y -> Z
      when 25
        shift = @yRegister % 32
        @log.debug @, -> "sl is #{(@xRegister>>>(32-shift))}"
        @setZRegister(((@xRegister<<shift) | (@xRegister>>>(32-shift))) >>> 0)
        @updateCCFlags()
      # 26: X SLR Y -> Z
      when 26
        shift = @yRegister % 32
        @setZRegister(((@xRegister<<(32-shift)) | (@xRegister>>>shift)) >>> 0)
        @updateCCFlags()
      # 27: CMP log. X Y -> Z
      when 27
        # use >>> to get unsigned value
        @setZRegister(((@xRegister-@yRegister) & 0xFFFFFFFF) >>> 0)
        @updateCCFlags()
      # 28: 0->X
      when 28
        @setXRegister(0)
      # 29: 0xFFFFFFFF->X
      when 29
        @setXRegister(0xFFFFFFFF)
      # 30: 0->Y
      when 30
        @setYRegister(0)
      # 31: 0xFFFFFFFF->Y
      when 31
        @setYRegister(0xFFFFFFFF)
      else
        @log.debug -> "fc else..."
        # 32-47: FC-32->X, X->Z
        if fc >= 32 and fc < 48
          @setXRegister(fc-32)
          @setZRegister(@xRegister)
          @updateCCFlags()
        # 48-63: FC-48->Y, Y->Z
        else if fc >= 48 and fc < 64
          @setYRegister(fc-48)
          @setZRegister(@yRegister)
          @updateCCFlags()
    @setCCRegister(@ccFlags) if copyCC is on

  updateCCFlags: ->
    if @zRegister is 0
      @setCCFlags(8)
    else
      if Utils.isBitSet(@zRegister, 32) is on
        @setCCFlags(2)
      else
        @setCCFlags(4)

  notifyX: (x) ->
    @log.debug -> "notify X for  alu listeners #{@aluListeners}"
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

  reset: ->
    @log.debug -> "reset alu"
    @setFunctionCode 0

    # set register & flags to random values
    @setXRegister(Utils.randomBitSequence 32)
    @setYRegister(Utils.randomBitSequence 32)
    @setZRegister(Utils.randomBitSequence 32)
    @setCCRegister(Utils.randomBitSequence 4)
    @setCCFlags(Utils.randomBitSequence 4)
