$(document).on 'ready', ->
  
  $('.timepickerclass').datetimepicker
      format:'hh:mm A'
  $('#div_flight_line_servicing').on 'cocoon:after-insert', ->
    $('select.custom-select2').select2 theme: 'bootstrap'
    $('input').iCheck
      checkboxClass: 'icheckbox_square'
      radioClass: 'iradio_square'
      increaseArea: '10%'
    $('.timepickerclass').datetimepicker
      format:'hh:mm A'
    return
  $('#div_techlog_servicing').on 'cocoon:after-insert', ->
    $('select.custom-select2').select2 theme: 'bootstrap'
    $('input').iCheck
      checkboxClass: 'icheckbox_square'
      radioClass: 'iradio_square'
      increaseArea: '10%'
    $('.timepickerclass').datetimepicker
      format:'hh:mm A'
    return
