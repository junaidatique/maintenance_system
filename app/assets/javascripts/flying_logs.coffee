$(document).on 'ready', ->  
  $('.timepickerclass').datetimepicker
      format:'hh:mm A'
  $('#div_techlog_servicing').on 'cocoon:before-insert', (e, row) ->
    id = $(row.find('input.autocomplete')[0]).attr('id')
    $(row.find('input.autocomplete')[0]).attr('data-id-element', '#' + id + '_id')
    

  $('#div_techlog_servicing').on 'cocoon:after-insert', (e, row) ->
    $(".div_id_no_0").hide()

  $('#flying_log_sortie_attributes_sortie_code_c1').on 'ifUnchecked', (event) ->
    $("#div_techlog_servicing").show()
    console.log event.type + ' callback'
    return
