$(document).on 'ready', ->
  
  if $(".nested-fields").length > 0
    i = 0
    while i < $('.nested-fields').length
      $('#flying_log_techlogs_attributes_' + i + '_work_unit_code').attr \
        'data-id-element', '#flying_log_techlogs_attributes_' + i + '_work_unit_code_id'
      i++
  $('.timepickerclass').datetimepicker
    format: 'hh:mm A'

  $('#div_techlog_servicing').on 'cocoon:before-insert', (e, row) ->
    id = $(row.find('input.autocomplete')[0]).attr('id')
    console.log $(row.find('input.autocomplete')[0])
    $(row.find('input.autocomplete')[0]).attr('data-id-element', '#' + id + '_id')



  $('#flying_log_sortie_attributes_pilot_comment_satisfactory').on 'ifChecked', (event) ->
    $("#div_techlog_servicing").hide()
    return

  $('#flying_log_sortie_attributes_pilot_comment_un_satisfactory').on 'ifChecked', (event) ->
    $("#div_techlog_servicing").show()
    return
