class @AbstractController
  log = Utils.getLogger 'AbstractController'
  highlightClass = "success"
  highlightElement: (id) ->
    unless ($ id).hasClass highlightClass
      ($ id).addClass highlightClass
  unhighlightElement: (id) ->
    ($ id).removeClass highlightClass
  mkInputHandler: (input, base, mask,  callback) ->
    input = $ input
    input.keyup ->
      oldSelectionStart = input[0].selectionStart
      oldSelectionEnd = input[0].selectionEnd

      value = parseInt input.val(), base
      value = (value & mask) >>> 0

      callback value

      log.debug -> "setting caret start to #{oldSelectionStart}"
      log.debug -> "setting caret end to #{oldSelectionEnd}"

      input[0].selectionStart = oldSelectionStart
      input[0].selectionEnd = oldSelectionEnd
    