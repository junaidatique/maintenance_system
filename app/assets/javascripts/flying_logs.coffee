# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).on 'ready', ->
  $('#flying_log_log_date').datepicker
    dateFormat: 'dd/mm/yy'

  $('#div_flight_line_servicing').on 'cocoon:after-insert', ->
    $('input').iCheck
      checkboxClass: 'icheckbox_square'
      radioClass: 'iradio_square'
      increaseArea: '10%'
    $('.timepickerclass').datetimepicker
      format:'hh:mm A'
    return
