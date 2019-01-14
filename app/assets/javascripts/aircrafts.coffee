$(document).on 'ready', ->
  $('#div_part').on 'cocoon:after-insert', ->
    $('.datepicker').datepicker
      dateFormat: 'dd/mm/yy'
    $('select.custom-select2').select2 theme: 'bootstrap'
    $('input').iCheck
      checkboxClass: 'icheckbox_square'
      radioClass: 'iradio_square'
      increaseArea: '10%'
    $('.timepickerclass').datetimepicker
      format:'HH:mm'
    return