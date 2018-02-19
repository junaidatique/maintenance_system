$(document).on 'ready', ->
  $('.datepicker').datepicker
    dateFormat: 'dd/mm/yy'
  $('.custom-select2').select2 theme: 'bootstrap'
  $('input').iCheck
    checkboxClass: 'icheckbox_square'
    radioClass: 'iradio_square'
    increaseArea: '10%'
  if window.dt != undefined
    window.dt.destroy()
  dt = $('.data-tabled').DataTable(
    responsive: true
    bSort: false
    language: 'paginate':
      'previous': '<i class="fa fa-angle-left"></i>'
      'next': '<i class="fa fa-angle-right"></i>')
  window.dt = dt
  