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
      
    input.bind 'change keypress paste focus textInput input', ->
      oldSelectionStart = input[0].selectionStart
      oldSelectionEnd = input[0].selectionEnd

      value = parseInt input.val(), base
      value = (value & mask) >>> 0

      callback value

      log.debug -> "setting caret start to #{oldSelectionStart}"
      log.debug -> "setting caret end to #{oldSelectionEnd}"

      input[0].selectionStart = oldSelectionStart
      input[0].selectionEnd = oldSelectionEnd
  showSetValueModal: (initialValue, mask, format, callback) ->
    format16 = Math.ceil format / 4
    ($ "#modal-val-2-tf").val (Utils.decToBin initialValue, format)
    ($ "#modal-val-10-tf").val initialValue
    ($ "#modal-val-16-tf").val (Utils.decToHex initialValue, format16)
    cleanup = ->
      ($ "#modal-val-2-ctrl").removeClass "success"
      ($ "#modal-val-10-ctrl").removeClass "success"
      ($ "#modal-val-16-ctrl").removeClass "success"
      ($ "#modal-val-2-ctrl").removeClass "error"
      ($ "#modal-val-10-ctrl").removeClass "error"
      ($ "#modal-val-16-ctrl").removeClass "error"
      ($ "#modal-val-set-btn").prop "disabled", false
    mkErrorChecker = (mode) ->
      ->
        cleanup()
        value = parseInt ($ "#modal-val-#{mode}-tf").val(), mode
        if (value > mask) or ((value | mask) >>> 0) isnt mask or isNaN value
          ($ "#modal-val-#{mode}-ctrl").removeClass "success"
          ($ "#modal-val-set-btn").prop "disabled", true
          unless ($ "#modal-val-#{mode}-ctrl").hasClass "error"
            ($ "#modal-val-#{mode}-ctrl").addClass "error"
        else
          unless mode is 2
            ($ "#modal-val-2-tf").val (Utils.decToBin value, format)
          unless mode is 10
            ($ "#modal-val-10-tf").val value
          unless mode is 16
            ($ "#modal-val-16-tf").val (Utils.decToHex value, format16)
          ($ "#modal-val-#{mode}-ctrl").removeClass "error"
          ($ "#modal-val-set-btn").prop "disabled", false
          unless ($ "#modal-val-#{mode}-ctrl").hasClass "success"
            ($ "#modal-val-#{mode}-ctrl").addClass "success"
    for mode in [2,10,16]
      ($ "#modal-val-#{mode}-tf").unbind 'change keypress paste focus textInput input'
      ($ "#modal-val-#{mode}-tf").bind 'change keypress paste focus textInput input', (mkErrorChecker mode)
    ($ "#modal-val-set-btn").unbind 'click.modal_val'
    ($ "#modal-val-set-btn").bind 'click.modal_val',  =>
      callback parseInt ($ "#modal-val-10-tf").val()
      $('#modal-val').modal('hide')
    cleanup()
    ($ "#modal-val").modal('show')