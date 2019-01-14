class Datatable < AjaxDatatablesRails::Base
  def_delegator :@view, :link_to
  def_delegator :@view, :image_tag

  def fetch_records
    get_raw_records
  end

  def retrieve_records
    records = fetch_records
    records = filter_records(records)
    records = sort_records(records)     if datatable.orderable?
    records = paginate_records(records) if datatable.paginate?
    records
  end

  def records_total_count
    get_raw_records.count
  end

  def records_filtered_count
    filter_records(get_raw_records).count
  end

  def paginate_records(records)
    records.offset(datatable.offset).limit(datatable.per_page)
  end

  def sort_records(records)
    records
  end
end
