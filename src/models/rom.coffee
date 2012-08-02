class @Rom
  constructor: (@romListeners = []) ->
    @mcar = 0
    @memory = []

  setMcar: (m) ->
    @mcar = m
    @notifySetMcar(m)

  getMcar: ->
    @mcar

  setMicrocode: (at, mc) ->
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

  notifySetMcar: (val) ->
    listener.onSetMcar?(val) for listener in @romListeners

  notifySetMc: (at, val) ->
    listener.onSetMc?(at,val) for listener in @romListeners