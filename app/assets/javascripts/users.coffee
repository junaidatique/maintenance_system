# # Place all the behaviors and hooks related to the matching controller here.
# # All this logic will automatically be available in application.js.
# # You can use CoffeeScript in this file: http://coffeescript.org/
# $(document).ready ->
#   $('.js-search-category-multiple-select').select2
#     {
#       ajax: {
#         url: '/work_unit_codes/get_work_unit_codes'
#         dataType: 'json'
#         delay: 250
#         data: (params) ->
#           {
#             q: params.term
#             page: params.page
#           }
#         processResults: (data, params) ->
#           params.page = params.page or 1
#           {
#             results: data.items
#             pagination: more: params.page * 30 < data.total_count
#           }
#       }
      
#       minimumInputLength: 1
#       escapeMarkup: (markup) ->
#         markup
#     }
#   return
