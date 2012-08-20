class @Mac
  constructor: (@macListeners = []) ->
    @log = Utils.getLogger "MAC"
    @reset()

  setMacListeners: (l) ->
    @macListeners = l

  getMcarNext: ->
    @mcarNextRegister

  setMode: (val) ->
    val = Utils.sanitizeNum val, 0x3
    @mode = val
    @updateTimes4()
    @notifySetMode(@mode)

  setCC: (val) ->
    val = Utils.sanitizeNum val, 0xF
    @ccRegister = val
    @updateTimes4()
    @notifySetCC(@ccRegister)

  setMask: (val) ->
    val = Utils.sanitizeNum val, 0xF
    @maskRegister = val
    @updateTimes4()
    @notifySetMask(@maskRegister)

  setTimes4: (val) ->
    val = Utils.sanitizeNum val, 0x1
    @times4 = val
    @notifySetTimes4(@times4)

  setMcop: (val) ->
    val = Utils.sanitizeNum val, 0xFF
    @mcopRegister = val
    @updateTimes4()
    @notifySetMcop(@mcopRegister)

  setMcarNext: (val) ->
    val = Utils.sanitizeNum val, 0xFFF
    @mcarNextRegister = val
    @updateTimes4()
    @notifySetMcarNext(@mcarNextRegister)

  setMcn: (val) ->
    val = Utils.sanitizeNum val, 0x3F
    @mcnRegister = val
    mask = Utils.extractNum val, 1, 4
    @setMask mask
    @updateTimes4()
    @notifySetMcn(@mcnRegister)

  setMcar: (val) ->
    val = Utils.sanitizeNum val, 0xFFF
    @mcarRegister = val
    @updateTimes4()
    @notifySetMcar(@mcarRegister)

  updateTimes4: ->
    switch @mode
      when 3
        jumpMode = Utils.extractNum(@mcnRegister, 5, 6)
        switch jumpMode
          when 1
            if ((@maskRegister & @ccRegister) >>> 0) isnt 0
              @setTimes4 1
            else
              @setTimes4 0
          when 2
            if ((@maskRegister & @ccRegister) >>> 0) is 0
              @setTimes4 1
            else
              @setTimes4 0
          else
            @setTimes4 0
      else
        @setTimes4 0

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
