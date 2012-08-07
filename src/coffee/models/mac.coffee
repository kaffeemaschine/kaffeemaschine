class @Mac
  constructor: (@macListeners = []) ->
    @log = Utils.getLogger "MAC"
    @reset()

  setMacListeners: (l) ->
    @macListeners = l

  getMcarNext: ->
    @mcarNextRegister

  setMode: (val) ->
    @log.debug -> "val=#{val}, mode=#{(val & 0x3) >>> 0}"
    @mode = (val & 0x3) >>> 0
    @notifySetMode(@mode)

  setCC: (val) ->
    @ccRegister = (val & 0xF) >>> 0
    @notifySetCC(@ccRegister)

  setMask: (val) ->
    @maskRegister = (val & 0xF) >>> 0
    @notifySetMask(@maskRegister)

  setTimes4: (val) ->
    @times4 = (val & 0x1) >>> 0
    @notifySetTimes4(@times4)

  setMcop: (val) ->
    @mcopRegister = (val & 0xFF) >>> 0
    @notifySetMcop(@mcopRegister)

  setMcarNext: (val) ->
    @mcarNextRegister = (val & 0xFFF) >>> 0
    @notifySetMcarNext(@mcarNextRegister)

  setMcn: (val) ->
    @mcnRegister = (val & 0x3F) >>> 0
    @notifySetMcn(@mcnRegister)

  setMcar: (val) ->
    @mcarRegister = (val & 0xFFF) >>> 0
    @notifySetMcar(@mcarRegister)

  compute: ->
    switch @mode
      when 0
        @setMcarNext(4 * @mcnRegister)
      when 1
        @setMcarNext(@mcarRegister + 1 + 4 * @mcnRegister)
      when 2
        @setMcarNext(@mcarRegister + 1 - 4 * @mcnRegister)
      when 3
        jumpMode = Utils.extractNum(@mcnRegister, 5, 6)
        switch jumpMode
          when 0
            @setMcarNext(4 * @mcopRegister)
          when 1
            if ((@maskRegister & @ccRegister) >>> 0) isnt 0
              @setMcarNext(4 * @mcopRegister)
            else
              @setMcarNext(@mcarRegister + 1)
          when 2
            if ((@maskRegister & @ccRegister) >>> 0) is 0
              @setMcarNext(4 * @mcopRegister)
            else
              @setMcarNext(@mcarRegister + 1)
          when 3
            @setMcarNext(@mcarRegister + 1)

  notifySetMode : (val) ->
    listener.onSetMode?(val) for listener in @macListeners
  notifySetCC : (val) ->
    listener.onSetCC?(val) for listener in @macListeners
  notifySetMask : (val) ->
    listener.onSetMask?(val) for listener in @macListeners
  notifySetTimes4 : (val) ->
    listener.onSetTimes4?(val) for listener in @macListeners
  notifySetMcop : (val) ->
    listener.onSetMcop?(val) for listener in @macListeners
  notifySetMcarNext : (val) ->
    listener.onSetMcarNext?(val) for listener in @macListeners
  notifySetMcn : (val) ->
    listener.onSetMcn?(val) for listener in @macListeners
  notifySetMcar : (val) ->
    listener.onSetMcar?(val) for listener in @macListeners

  reset: () ->
    @setMode 0
    @setCC(Utils.randomBitSequence 4)
    @setMask 0
    @setTimes4 0
    @setMcop 0
    @setMcarNext(Utils.randomBitSequence 12)
    @setMcn 0
    @setMcar(Utils.randomBitSequence 12)
