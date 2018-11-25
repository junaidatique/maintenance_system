$(document).on 'ready', ->
  
  if $(".nested-fields").length > 0
    i = 0
    while i < $('.nested-fields').length
      $('#flying_log_techlogs_attributes_' + i + '_work_unit_code').attr \
        'data-id-element', '#flying_log_techlogs_attributes_' + i + '_work_unit_code_id'
      i++
  $('.timepickerclass').datetimepicker
    format:'HH:mm'

  $('#div_techlog_servicing').on 'cocoon:before-insert', (e, row) ->
    id = $(row.find('input.autocomplete')[0]).attr('id')    
    $(row.find('input.autocomplete')[0]).attr('data-id-element', '#' + id + '_id')


  
  $('#flying_log_ac_configuration_attributes_cockpit_single').on 'ifChecked', (event) -> 
    console.log 'here'   
    $(".flying_log_capt_acceptance_certificate_second_pilot").addClass('hide');
    return
  
  $('#flying_log_ac_configuration_attributes_cockpit_dual').on 'ifChecked', (event) ->    
    $(".flying_log_capt_acceptance_certificate_second_pilot").removeClass('hide');
    return

  

  $('#flying_log_ac_configuration_attributes_smoke_pods').on 'ifChecked', (event) ->    
    $(".smoke-oil-quantity").removeClass('hide')
    return
  
  $('#flying_log_ac_configuration_attributes_smoke_pods').on 'ifUnchecked', (event) ->    
    $(".smoke-oil-quantity").addClass('hide')
    return
  
  $('#flying_log_sortie_attributes_pilot_comment_satisfactory').on 'ifChecked', (event) ->    
    $("#div_techlog_servicing").addClass('hide')
    return

  $('#flying_log_sortie_attributes_pilot_comment_un_satisfactory').on 'ifChecked', (event) ->
    $("#div_techlog_servicing").removeClass('hide')
    return

  $('#flying_log_sortie_attributes_pilot_comment_mission_cancelled').on 'ifChecked', (event) ->
    $("#div_techlog_servicing").addClass('hide')
    return
