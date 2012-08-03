class @RomListener
  constructor: (@onSetMc = undefined, @onSetMcar = undefined) ->

  setOnSetMc: (f) ->
    @onSetMc = f

  setOnSetMcar: (f) ->
    @onSetMcar = f