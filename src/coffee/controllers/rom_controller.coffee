class @RomController extends AbstractController
  constructor: (@rom) ->
    @log = Utils.getLogger 'RomController'
    @initRomModal()
    @initListener()
    @initButtonHandlers()


  initRomModal: ->
    for row in [0..1023]
      ($ '#modal-rom-table > tbody:last').append "
  <tr id=\"modal-rom-row-#{row}\">
    <td>#{Utils.decToHex row, 3}</td>
    <td id=\"modal-rom-#{row}-tf\">
    00 000000 0000000 00000000 00000000 00000000 00000000 00
    </td>
  </tr>"
    for fc in [0..127]
      ($ '#modal-rom-alufc-sl').append "
        <option value=\"#{fc}\">
        #{Utils.decToBin fc, 7}: #{Utils.functionCodeToText fc}
        </option>"
    

    parseRomId = (id) ->
      [u,v,w,row] = id.split "-"
      parseInt row

    hasErrors = ->
      if ($ "#modal-rom-mask-ctrl").hasClass "error"
        return true
      false

    errorChecker = ->
      mask = 0xF
      value = parseInt ($ "#modal-rom-mask-tf").val(), 2
      if (value > mask) or ((value | mask) >>> 0) isnt mask or isNaN value
        ($ "#modal-rom-mask-ctrl").removeClass "success"
        ($ "#modal-rom-set-btn").prop "disabled", true
        unless ($ "#modal-rom-mask-ctrl").hasClass "error"
          ($ "#modal-rom-mask-ctrl").addClass "error"
      else
        ($ "#modal-rom-mask-ctrl").removeClass "error"
        unless hasErrors()
          ($ "#modal-rom-set-btn").prop "disabled", false
        unless ($ "#modal-rom-mask-ctrl").hasClass "success"
          ($ "#modal-rom-mask-ctrl").addClass "success"

    doUpdate = (row) =>
      mc = @rom.getMicrocode row
      ($ "#modal-rom-mode-sl option[value='#{mc.mode}']").attr 'selected', true
      smode = Utils.extractNum mc.mcnext, 5, 6
      mask = Utils.extractNum mc.mcnext, 1, 4
      ($ "#modal-rom-smode-sl option[value='#{smode}']").attr 'selected', true
      ($ '#modal-rom-mask-tf').val (Utils.decToBin mask, 4)
      ($ "#modal-rom-alufc-sl
        option[value='#{mc.alufc}']").attr 'selected', true
      for bit in [1..8]
        if Utils.isBitSet mc.xbus, bit
          ($ "#modal-rom-x-#{bit}-cb").attr 'checked', true
        else
          ($ "#modal-rom-x-#{bit}-cb").attr 'checked', false
        if Utils.isBitSet mc.ybus, bit
          ($ "#modal-rom-y-#{bit}-cb").attr 'checked', true
        else
          ($ "#modal-rom-y-#{bit}-cb").attr 'checked', false
        if Utils.isBitSet mc.zbus, bit
          ($ "#modal-rom-z-#{bit}-cb").attr 'checked', true
        else
          ($ "#modal-rom-z-#{bit}-cb").attr 'checked', false
      for bit in [3..8]
        if Utils.isBitSet mc.ioswitch, bit
          ($ "#modal-rom-ioswitch-#{bit}-cb").attr 'checked', true
        else
          ($ "#modal-rom-ioswitch-#{bit}-cb").attr 'checked', false
      ($ "#modal-rom-ram-mode-sl
          option[value='#{(mc.ioswitch & 0x3) >>> 0}']").attr 'selected', true
      ($ "#modal-rom-ram-format-sl
          option[value='#{mc.byte}']").attr 'selected', true
      ($ '#modal-rom-mnemonic-tf').val mc.mnemonic
      ($ '#modal-rom-remarks-tf').val mc.remarks

    # make rows clickable
    ($ '#modal-rom-table tbody tr').click ->
      ($ '#modal-rom-table tbody tr').removeClass 'rom-selection-highlight'
      unless ($ @).hasClass 'rom-selection-highlight'
        ($ @).addClass 'rom-selection-highlight'
        doUpdate (parseRomId (($ @).attr 'id'))

    # error checker
    ($ "#modal-rom-mask-tf").bind 'change keypress paste
        focus textInput input', errorChecker

    # set button
    ($ '#modal-rom-set-btn').click =>
      row = parseRomId (@getSelectedRomRow().attr 'id')
      mask = parseInt ($ "#modal-rom-mask-tf").val(), 2
      smode = ($ "#modal-rom-smode-sl option:selected").val()
      x = 0
      y = 0
      z = 0
      io = ($ "#modal-rom-ram-mode-sl option:selected").val()
      for bit in [1..8]
        if (($ "#modal-rom-x-#{bit}-cb").attr 'checked')?
          x = Utils.setBit x, bit
        if (($ "#modal-rom-y-#{bit}-cb").attr 'checked')?
          y = Utils.setBit y, bit
        if (($ "#modal-rom-z-#{bit}-cb").attr 'checked')?
          z = Utils.setBit z, bit
      for bit in [3..8]
        if (($ "#modal-rom-ioswitch-#{bit}-cb").attr 'checked')?
          io = Utils.setBit io, bit
      mc =
        mode: ($ "#modal-rom-mode-sl option:selected").val()
        mcnext: ((smode << 4) | mask) >>> 0
        alufc: ($ "#modal-rom-alufc-sl option:selected").val()
        xbus: x
        ybus: y
        zbus: z
        ioswitch: io
        byte: ($ "#modal-rom-ram-format-sl option:selected").val()
        mnemonic: ($ '#modal-rom-mnemonic-tf').val()
        remarks: ($ '#modal-rom-remarks-tf').val()
      @rom.setMicrocode row, mc

  initListener: ->
    @romListener = new RomListener()
    @romListener.setOnSetMc (at, mc) ->
      text = "#{Utils.decToBin mc.mode, 2}
 #{Utils.decToBin mc.mcnext, 6}
 #{Utils.decToBin mc.alufc, 7}
 #{Utils.decToBin mc.xbus, 8}
 #{Utils.decToBin mc.ybus, 8}
 #{Utils.decToBin mc.zbus, 8}
 #{Utils.decToBin mc.ioswitch, 8}
 #{Utils.decToBin mc.byte, 2}"
      ($ "#modal-rom-#{at}-tf").html text
    @romListener.setOnSetMcar (val) ->
      ($ "#rom-mcar-tf").val (Utils.decToHex val, 3)
    @log.debug -> 'setting rom listener'
    @rom.setRomListeners [@romListener]

  initButtonHandlers: ->
    ($ "#rom-rom-btn").click =>
      @showRomModal()
    ($ "#rom-mcar-btn").click =>
      @showSetValueModal @rom.getMcar(), 0xFFF, 12, (val) =>
        @rom.setMcar val

   getSelectedRomRow: ->
    # find selection row
    row = ($ '#modal-rom-table
              tbody
              tr[class~="rom-selection-highlight"]')
    if row.length isnt 1
      #backup to default selection
      ($ '#modal-rom-table tbody tr').removeClass 'rom-selection-highlight'
      row = ($ '#modal-rom-table tbody tr:first-child')
    row

  showRomModal: ->
    row = @getSelectedRomRow()
    # update values
    row.trigger('click')
    ($ '#modal-rom').modal('show')
