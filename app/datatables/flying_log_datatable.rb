class FlyingLogDatatable < Datatable

  def_delegator :@view, :flying_log_path
  def_delegator :@view, :edit_flying_log_path
  def_delegator :@view, :params

  def initialize(view, current_user, flying_logs)
    @view = view    
    @flying_logs = flying_logs
    @current_user = current_user
  end
  def display_date(input_date)
    unless input_date.blank?
      return input_date.strftime("%d-%m-%Y")
    end
  end

  def view_columns
    # Declare strings in this format: ModelName.column_name
    # or in aliased_join_table.column_name format
    # @view_columns ||= {
      # id: { source: "User.id", cond: :eq },
      # name: { source: "User.name", cond: :like }
    # }
  end

  def data
    records.map do |flying_log|
      [
        # link_to flying_log.serial_no, flying_log_path(flying_log), target: "_blank"
        link_to(flying_log.serial_no, flying_log_path(flying_log)),
        self.display_date(flying_log.log_date),
        flying_log.aircraft.tail_number,
        status(flying_log),
        # link_to('<i class="fa fa-eye"></i>'.html_safe, flying_log_path(flying_log), target: "_blank", class: 'btn btn-success btn-flat'),
        link_to('<i class="fa fa-pencil"></i>'.html_safe, edit_flying_log_path(flying_log), class: 'btn btn-info btn-flat ')
      ]
    end
  end

  private

  def get_raw_records
    @flying_logs
  end
  

  # ==== These methods represent the basic operations to perform on records
  # and feel free to override them

  def filter_records(records)
    records.where(serial_no: /#{params['search']['value']}.*/i)
    # records
  end
  def status flying_log
    if (flying_log.log_completed?)
      'Completed'
    elsif flying_log.flight_cancelled?
      'Cancelled'
    else 
      'Open'
    end
  end

  # def sort_records(records)
  # end

  # def paginate_records(records)
  # end

  
  # ==== Insert 'presenter'-like methods below if necessary
end
