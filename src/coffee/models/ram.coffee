class @Ram
  constructor: (@eventListeners = []) ->
    @log = Utils.getLogger "Ram"
    @reset()
    # 4byte/index, 16K total
    @memory = [ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

  setMode: (m) ->
    @mode = m
    @notifyMode(m)

  setFormat: (f) ->
    @format = f
    @notifyFormat(f)
    # update mdr to new format
    @setMdr(@mdr)

  setMar: (value) ->
    value = Utils.sanitizeNum value, 0x7FF
    @mar = value
    @notifyMar(@mar)

  setMdr: (m) ->
    if isNaN m
      m = 0
    @mdr = Utils.extractNum(m, 1, 1 + (@format+1)*8)
    @notifyMdr(@mdr)

  getMdr: ->
    @mdr


  getMar: ->
    @mar

  compute: ->
    @log.debug => "ram mode is"
    switch @mode
      when 1
        @log.debug -> "ram is reading..."
        @read()
      when 2
        @log.debug -> "ram is writing..."
        @write()

  read: ->
    mem = 0
    switch @format
      when 0 then mem = @getByte(@mar)
      when 1 then mem = ((@getByte(@mar)<<8) | @getByte(@mar+1)) >>> 0
      when 2
        mem = @getByte(@mar)<<16
        mem |= @getByte(@mar+1)<<8
        mem |= @getByte(@mar+2)
        mem = mem >>> 0
      when 3
        mem = @getByte(@mar)<<24
        mem |= @getByte(@mar+1)<<16
        mem |= @getByte(@mar+2)<<8
        mem |= @getByte(@mar+3)
        mem |= mem >>> 0
    @setMdr(mem)

  write: ->
    for at in [0..@format]
      @log.debug @, -> "l: #{(@format-at)*8+1} r: #{(@format-at)*8+8}"
      @log.debug @, -> "writing @#{@mar+at} #{Utils.extractNum(@mdr,
                         (@format-at)*8+1, (@format-at)*8+8).toString(16)}"
      @setByte(@mar+at, Utils.extractNum(@mdr, (@format-at)*8+1,
                (@format-at)*8+8))

  getByte: (at) ->
    index = Math.floor(at/4)
    offset = at % 4
    mem = @memory[index]
    byte = 0
    switch offset
      when 0 then byte = Utils.extractNum(mem, 25, 32)
      when 1 then byte = Utils.extractNum(mem, 17, 24)
      when 2 then byte = Utils.extractNum(mem, 9, 16)
      when 3 then byte = Utils.extractNum(mem, 1, 8)
    return byte

  setByte: (at, val) ->
    val = Utils.sanitizeNum val, 0xFF
    index = Math.floor(at/4)
    offset = at % 4
    for bit in [1..8]
      if Utils.isBitSet(val, bit) is true
        @memory[index] = Utils.setBit(@memory[index], bit + 8*(3-offset))
    @notifySetByte(at,val)

  setRamListeners: (listeners) ->
    @eventListeners = listeners

  notifySetByte: (at, val) ->
    listener.onSetByte?(at,val) for listener in @eventListeners

  notifyMode: (m) ->
    listener.onSetMode?(m) for listener in @eventListeners

  notifyFormat: (m) ->
    listener.onSetFormat?(m) for listener in @eventListeners

  notifyMar: (m) ->
    listener.onSetMar?(m) for listener in @eventListeners

  notifyMdr: (m) ->
    listener.onSetMdr?(m) for listener in @eventListeners

  reset: () ->
    @setMode 0
    @setFormat 0
    @setMar(Utils.randomBitSequence 12)
    @setMdr 0
