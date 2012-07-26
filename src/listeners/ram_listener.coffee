class @RamListener
  constructor: (@onSetFormat = undefined, @onSetMode = undefined, @onSetMar = undefined, @onSetMdr = undefined) ->
  setOnSetFormat: (f) ->
    @onSetFormat = f
  setOnSetMode: (f) ->
    @onSetMode = f
  setOnSetMar: (f) ->
    @onSetMar = f
  setOnSetMdr: (f) ->
    @onSetMdr = f