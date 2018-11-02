
aircraft = Aircraft.where(tail_number: 'QA300').first
aircraft.import './xlsx/300.xlsx'
aircraft = Aircraft.where(tail_number: 'QA301').first
aircraft.import './xlsx/301.xlsx'
aircraft = Aircraft.where(tail_number: 'QA302').first
aircraft.import './xlsx/302.xlsx'
aircraft = Aircraft.where(tail_number: 'QA303').first
aircraft.import './xlsx/303.xlsx'

# workbook = Roo::Spreadsheet.open './xlsx/300.xlsx'
# worksheets = workbook.sheets
# puts "Found #{worksheets.count} worksheets"

# worksheets.each do |worksheet|
#   puts "Reading: #{worksheet}"
#   num_rows = 0
#   workbook.sheet(worksheet).each_row_streaming do |row|
#     row_cells = row.map { |cell| cell.value }
#     num_rows += 1
#   end
#   puts "Read #{num_rows} rows" 
# end