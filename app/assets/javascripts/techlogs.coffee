$(document).on 'ready', ->
  $('#techlog-tabled').dataTable
    scrollY: '47vh'
    scrollCollapse: true
    processing: true
    serverSide: true
    pageLength: 50
    bSort: false
    "pagingType": "simple_numbers"
    ajax:
      url: $("#techlog-tabled").data('source'),      
  $('.date_class').datepicker
    dateFormat: 'dd/mm/yy'
  $('#div_part_change').on 'cocoon:before-insert', (e, row) ->
    id = $(row.find('input.autocomplete')[0]).attr('id') 
    console.log id   
    $(row.find('input.autocomplete')[0]).attr('data-id-element', '#' + id + '_id')
    
  $('#div_assigned_tools').on 'cocoon:before-insert', (e, row) ->
    id = $(row.find('input.autocomplete')[0]).attr('id')    
    $(row.find('input.autocomplete')[0]).attr('data-id-element', '#' + id + '_id')
    
  $('#div_part_change').on 'cocoon:after-insert', ->    
    $('select.custom-select2').select2 theme: 'bootstrap'
    $('input').iCheck
      checkboxClass: 'icheckbox_square'
      radioClass: 'iradio_square'
      increaseArea: '10%'
    $('.timepickerclass').datetimepicker
      format:'HH:mm'
    return
  
  if ($('[name="techlog[condition]"]:checked').val() == 'open')
    $(".action_div").addClass 'hide'
  else
    $(".action_div").removeClass 'hide'          

  $('#techlog_condition_interm').on 'ifChecked', (event) ->
    $(".action_div").removeClass 'hide'
  $('#techlog_condition_completed').on 'ifChecked', (event) ->
    $(".action_div").removeClass 'hide'
  $('#techlog_condition_open').on 'ifChecked', (event) ->
    $(".action_div").addClass 'hide'


  $('.techlog_change_parts_available input[type="checkbox"]').on 'ifUnchecked', (evnet) ->
    $(".addition_values").removeClass 'hide'
  $('.techlog_change_parts_available input[type="checkbox"]').on 'ifChecked', (evnet) ->
    $(".addition_values").addClass 'hide'

  