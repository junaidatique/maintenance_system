class HistoryDatatable < Datatable

  def_delegator :@view, :techlog_path
  def_delegator :@view, :edit_techlog_path
  def_delegator :@view, :pdf_techlog_path
  def_delegator :@view, :params

  def initialize(view, current_user, techlogs)
    @view = view
    @techlogs = techlogs
    @current_user = current_user
  end
  def display_date(input_date)
    unless input_date.blank?
      return input_date.strftime("%d-%m-%Y")
    end
  end

  def data
    records.map do |techlog|
      [        
        techlog.user.name,
        display_date(techlog.log_date),
        techlog.description,                
        (techlog.autherization_code.present?) ? techlog.autherization_code.autherization_code_format : '',
        techlog.action,
        link_to('<i class="fa fa-file-pdf-o"></i>'.html_safe, pdf_techlog_path(techlog, format: :pdf), class: 'btn btn-info btn-flat', target: :_blank)
      ]
    end
  end

  private

  def paginate_records(records)
    # records.offset(datatable.offset).limit(datatable.per_page)
    records.slice(datatable.offset, datatable.per_page)
  end

  def get_raw_records
    @techlogs
  end
  
  def filter_records(records)
    records
  end

end
