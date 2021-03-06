flying_day_checked = ->
    $('.flying-aircrafts').removeClass 'hide'
    $('.non-flying-reason').addClass 'hide'
    return
flying_day_unchecked = ->
  $(".flying-aircrafts").addClass('hide')
  $(".non-flying-reason").removeClass('hide')
  return
$(document).on 'ready', ->
  $('#flying_plan_is_flying_true').on 'ifChecked', (event) ->
    flying_day_checked()
  $('#flying_plan_is_flying_false').on 'ifChecked', (event) ->
    flying_day_unchecked()



  format_aircraft = (aircraft) ->
    if aircraft.loading
      return 'Loading...'
    markup = '<div class=\'select2-result-aircraft clearfix\'>'
    aircraft.tail_number

  format_aircraft_selection = (aircraft) ->
    aircraft.tail_number or aircraft.text

  window.select2_multisearch '.aircraft-select2', '/aircrafts/get_aircrafts', format_aircraft, format_aircraft_selection

  if $('#flying_plan_is_flying_true').is(":checked")
    flying_day_checked()
  else 
    flying_day_unchecked()

  
  
