$(document).ready ->
  formatwuc = (wuc) ->
    if wuc.loading
      return 'Loading...'
    markup = '<div class=\'select2-result-wuc clearfix\'>'
    wuc.code

  formatwucSelection = (wuc) ->
    wuc.code or wuc.text

  window.select2_multisearch '.wuc-select2', '/work_unit_codes/get_work_unit_codes', formatwuc, formatwucSelection
  
