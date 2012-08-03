class @RamListener
  constructor: (@onSetFormat = undefined, @onSetMode = undefined,
      @onSetMar = undefined, @onSetMdr = undefined, @onSetByte = undefined) ->
  setOnSetFormat: (f) ->
    @onSetFormat = f
  setOnSetMode: (f) ->
    @onSetMode = f
  setOnSetMar: (f) ->
    @onSetMar = f
  setOnSetMdr: (f) ->
    @onSetMdr = f
  setOnSetByte: (f) ->
    @onSetByte = f
