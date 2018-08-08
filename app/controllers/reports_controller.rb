class ReportsController < ApplicationController
  def airframe
    
  end
  def airframe_pdf
    i = 0
    if params[:aircraft].blank? or Aircraft.find(params[:aircraft]).blank?
      redirect_to airframe_reports_path(), :flash => { :error => "Invalid aircraft." }
    end
    if params[:from_date].blank? and params[:to_date].blank? 
      @histories = Aircraft.find(params[:aircraft]).flying_histories.limit(30).order(id: :asc)
    else
      @histories = Aircraft.find(params[:aircraft]).flying_histories.gte(created_at: params[:from_date]).lte(created_at: params[:to_date])  
    end
    
    num = @histories.count
    merged_certificates = CombinePDF.new
    
    begin
      histories  = @histories.limit(8).offset(i)      
      pdf_data = render_to_string(
                  pdf: "airframe_report",
                  orientation: 'Landscape',
                  template: 'reports/airframe_pdf.html.slim',
                  layout: 'layouts/pdf/pdf.html.slim',
                  show_as_html: false,
                  locals: {
                    histories: histories
                  },
                  page_height: '17in',
                  page_width: '9in',
                  margin:  {
                    top: 0,
                    bottom: 0,
                    left: 0,
                    right:0 
                  }
                )
              
      merged_certificates  << CombinePDF.parse(pdf_data)
      i +=8
    end while i < num
    send_data merged_certificates.to_pdf, :disposition => 'inline', :type => "application/pdf"
  end
  def inspection_record_pdf
    i = 0
    if params[:aircraft].blank? or Aircraft.find(params[:aircraft]).blank?
      redirect_to aircrafts_path(), :flash => { :error => "Invalid aircraft." }
    end
    if params[:trade].blank?
      redirect_to aircrafts_path(), :flash => { :error => "Invalid trade." }
    end
    # @all_parts = Aircraft.find(params[:aircraft]).parts.where(is_inspectable: true).where(trade_cd: params[:trade].to_i)
    scheduled_inspections = ScheduledInspection.in(inspectable_id: Aircraft.find(params[:aircraft]).parts.map(&:id)).not_completed.where(trade_cd: Part::trades[params[:trade]]).where(is_repeating: true)
    num = scheduled_inspections.count
    merged_certificates = CombinePDF.new
    page_no = 1
    begin
      sps  = scheduled_inspections.limit(8).offset(i)      
      pdf_data = render_to_string(
                    pdf: "inspection_record_report",
                    orientation: 'Landscape',
                    template: 'reports/inspection_record_pdf.html.slim',
                    layout: 'layouts/pdf/pdf.html.slim',
                    show_as_html: false,
                    locals: {
                      scheduled_inspections: sps,
                      page_no: page_no,
                      total: num,
                      trade: params[:trade]
                    },
                    page_height: '17in',
                    page_width: '9in',
                    margin:  {
                      top: 0,
                      bottom: 0,
                      left: 0,
                      right:0 
                    }
                  )
      merged_certificates  << CombinePDF.parse(pdf_data)
      i +=8
      page_no +=1
    end while i < num
    send_data merged_certificates.to_pdf, :disposition => 'inline', :type => "application/pdf"
    

  end
  def inspection_pdf
    i = 0
    if params[:aircraft].blank? or Aircraft.find(params[:aircraft]).blank?
      redirect_to aircrafts_path(), :flash => { :error => "Invalid aircraft." }
    end
    
    pdf_data = render(
                    pdf: "inspection_report",
                    orientation: 'Landscape',
                    template: 'reports/inspection_pdf.html.slim',
                    layout: 'layouts/pdf/pdf.html.slim',
                    show_as_html: false,
                    locals: {
                      aircraft: Aircraft.find(params[:aircraft])
                    },
                    page_height: '17in',
                    page_width: '13in',
                    margin:  {
                      top: 0,
                      bottom: 0,
                      left: 0,
                      right:0 
                    }
                  )
  end
  def tyre_record_pdf
    i = 0
    if params[:aircraft].blank? or Aircraft.find(params[:aircraft]).blank?
      redirect_to aircrafts_path(), :flash => { :error => "Invalid aircraft." }
    end
    
    pdf_data = render(
                    pdf: "tyre_record",
                    orientation: 'Landscape',
                    template: 'reports/tyre_record_pdf.html.slim',
                    layout: 'layouts/pdf/pdf.html.slim',
                    show_as_html: false,
                    locals: {
                      aircraft: Aircraft.find(params[:aircraft])
                    },
                    page_height: '17in',
                    page_width: '13in',
                    margin:  {
                      top: 0,
                      bottom: 0,
                      left: 0,
                      right:0 
                    }
                  )
  end
  def history_pdf
    i = 0
    if params[:aircraft].blank? or Aircraft.find(params[:aircraft]).blank?
      redirect_to aircrafts_path(), :flash => { :error => "Invalid aircraft." }
    end
    
    pdf_data = render(
                    pdf: "history_pdf",
                    orientation: 'Portrait',
                    template: 'reports/history_pdf.html.slim',
                    layout: 'layouts/pdf/pdf.html.slim',
                    show_as_html: false,
                    locals: {
                      aircraft: Aircraft.find(params[:aircraft])
                    },
                    page_height: '17in',
                    page_width: '13in',
                    margin:  {
                      top: 10,
                      bottom: 10,
                      left: 5,
                      right:5 
                    }
                  )
  end
  
end
