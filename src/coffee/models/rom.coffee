class @Rom
  constructor: (@romListeners = []) ->
    @reset()
    @memory = []

  setMcar: (m) ->
    m = Utils.sanitizeNum m, 0xFFF
    @mcar = m
    @notifySetMcar(m)

  getMcar: ->
    @mcar

  setMicrocode: (at, mc) ->
    mc = Utils.sanitizeMicrocode mc
    @memory[at] = mc
    @notifySetMc(at, mc)

  getMicrocode: (at) ->
    mc =
      mode: 0
      mcnext: 0
      alufc: 0
      xbus: 0
      ybus: 0
      zbus: 0
      ioswitch: 0
      byte: 0
      mnemonic: ""
      remarks: ""
    mc = @memory[at] if @memory[at]?
    return mc

  read: ->
    return @getMicrocode(@mcar)

  setRomListeners: (listeners) ->
    @romListeners = listeners

  notifySetMcar: (val) ->
    listener.onSetMcar?(val) for listener in @romListeners

  notifySetMc: (at, val) ->
    listener.onSetMc?(at,val) for listener in @romListeners

  reset: () ->
    @setMcar 0
