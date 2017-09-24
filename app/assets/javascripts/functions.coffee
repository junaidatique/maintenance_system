window.select2_multisearch = (class_name, url, format_fun, format_selection) ->
  $(class_name).select2
    theme: 'bootstrap'
    ajax:
      url: url
      dataType: 'json'
      type: 'GET'
      delay: 250
      data: (params) ->
        {
          q: params.term
          page: params.page
        }
      processResults: (data, params) ->
        params.page = params.page or 1
        {
          results: data.items
          pagination: more: params.page * 30 < data.total_count
        }
    minimumInputLength: 1
    escapeMarkup: (markup) ->
      markup
    templateResult: format_fun
    templateSelection: format_selection
  return
