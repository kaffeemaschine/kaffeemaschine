class @Mac
  constructor: (@macListeners = []) ->
    @reset()

  setMacListeners: (l) ->
    @macListeners = l

  setMode: (val) ->
    @mode = val
    @notifySetMode(val)

  setCC: (val) ->
    @ccRegister = val
    @notifySetCC(val)

  setMask: (val) ->
    @maskRegister = val
    @notifySetMask(val)

  setTimes4: (val) ->
    @times4 = val
    @notifySetTimes4(val)

  setMcop: (val) ->
    @mcopRegister = val
    @notifySetMcop(val)

  setMcarNext: (val) ->
    @mcarNextRegister = val
    @notifySetMcarNext(val)

  setMcn: (val) ->
    @mcnRegister = val
    @notifySetMcn(val)

  setMcar: (val) ->
    @mcarRegister = val
    @notifySetMcar(val)

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
