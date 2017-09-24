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
      format:'hh:mm A'
    return