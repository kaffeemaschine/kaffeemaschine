class @Ram
  constructor: (@eventListeners = []) ->
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

  setMar: (m) ->
    @mar = (m & 0x7FF) >>> 0
    @notifyMar(@mar)

  setMdr: (m) ->
    @mdr = Utils.extractNum(m, 1, 1 + (@format+1)*8)
    @notifyMdr(@mdr)

  getMdr: ->
    @mdr


  getMar: ->
    @mar

  read: ->
    mem = 0
    switch @format
      when 0 then mem = @getByte(@mar)
      when 1 then mem = ((@getByte(@mar)<<8) | @getByte(@mar+1)) >>> 0
      when 2 then mem = (((@getByte(@mar)<<16) | (@getByte(@mar+1)<<8))  | @getByte(@mar+2)) >>> 0
      when 3 then mem = ((((@getByte(@mar)<<24) | (@getByte(@mar+1)<<16))  | (@getByte(@mar+2)<<8)) | @getByte(@mar+3)) >>> 0
    @setMdr(mem)

  write: ->
    for at in [0..@format]
      console.log "l: #{(@format-at)*8+1} r: #{(@format-at)*8+8}"
      console.log "writing @#{@mar+at} #{Utils.extractNum(@mdr, (@format-at)*8+1, (@format-at)*8+8).toString(16)}"
      @setByte(@mar+at, Utils.extractNum(@mdr, (@format-at)*8+1, (@format-at)*8+8))

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
    index = Math.floor(at/4)
    offset = at % 4
    for bit in [1..8]
      @memory[index] = Utils.setBit(@memory[index], bit + 8*(3-offset)) if Utils.isBitSet(val, bit) is true
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
