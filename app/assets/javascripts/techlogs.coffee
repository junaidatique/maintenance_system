$(document).on 'ready', ->
  $('.date_class').datepicker
    dateFormat: 'dd/mm/yy'
  $('#div_part_change').on 'cocoon:after-insert', ->
    $('select.custom-select2').select2 theme: 'bootstrap'
    $('input').iCheck
      checkboxClass: 'icheckbox_square'
      radioClass: 'iradio_square'
      increaseArea: '10%'
    $('.timepickerclass').datetimepicker
      format: 'hh:mm A'
    return

  $('#techlog_condition_interm').on 'ifChecked', (event) ->
    $(".action_div").removeClass 'hide'
  $('#techlog_condition_completed').on 'ifChecked', (event) ->
    $(".action_div").removeClass 'hide'
  $('#techlog_condition_open').on 'ifChecked', (event) ->
    $(".action_div").addClass 'hide'

  format_parts = (wuc) ->
    if wuc.loading
      return 'Loading...'
    markup = '<div class=\'select2-result-wuc clearfix\'>'
    wuc.code

  formatPartsSelection = (wuc) ->
    wuc.code or wuc.text

  window.select2_multisearch '.wuc-select2', '/parts/get_parts?', format_parts, formatPartsSelection