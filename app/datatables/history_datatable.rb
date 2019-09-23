class TechlogDatatable < Datatable

  def_delegator :@view, :techlog_path
  def_delegator :@view, :edit_techlog_path
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
        (techlog.type_cd == 1) ? link_to(techlog.serial_no, techlog_path(techlog), class: 'error') : link_to(techlog.serial_no, techlog_path(techlog)), 
        techlog.type,
        (techlog.aircraft.present?) ? techlog.aircraft.tail_number : '',
        techlog.description,
        (techlog.autherization_code.present?) ? techlog.autherization_code.autherization_code_format : '',
        techlog.condition.to_s.titleize,
        link_to('<i class="fa fa-pencil"></i>'.html_safe, edit_techlog_path(techlog), class: 'btn btn-info btn-flat ')
      ]
    end
  end

  private

  def get_raw_records
    @techlogs
  end
  
  def filter_records(records)
    records.where(serial_no: /#{params['search']['value']}.*/i)
  end

end
