class ReportsController < ApplicationController
  def airframe
    
  end
  def airframe_pdf
    i = 0
    if params[:aircraft].blank? or Aircraft.find(params[:aircraft]).blank?
      redirect_to airframe_reports_path(), :flash => { :error => "Invalid aircraft." }
    end
    if params[:from_date].blank? and params[:to_date].blank? 
      @flying_logs = Aircraft.find(params[:aircraft]).flying_logs.limit(30).order(id: :asc)
    else
      @flying_logs = Aircraft.find(params[:aircraft]).flying_logs.gte(created_at: params[:from_date]).lte(created_at: params[:to_date])  
    end
    
    num = @flying_logs.count
    merged_certificates = CombinePDF.new
    
    begin
      flying_logs  = @flying_logs.limit(8).offset(i)      
      pdf_data = render_to_string(
                  pdf: "airframe_report",
                  orientation: 'Landscape',
                  template: 'reports/airframe_pdf.html.slim',
                  layout: 'layouts/pdf/pdf.html.slim',
                  show_as_html: false,
                  locals: {
                    flying_logs: flying_logs
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
              
      merged_certificates  << CombinePDF.parse(pdf_data)
      i +=8
    end while i < num
    send_data merged_certificates.to_pdf, :disposition => 'inline', :type => "application/pdf"

    # ------------------------
    # pdf_data = render(
    #                 pdf: "airframe_report",
    #                 orientation: 'Landscape',
    #                 template: 'reports/airframe_pdf.html.slim',
    #                 layout: 'layouts/pdf/pdf.html.slim',
    #                 show_as_html: false,
    #                 locals: {
    #                   flying_logs: @flying_logs
    #                 },
    #                 page_height: '17in',
    #                 page_width: '13in',
    #                 margin:  {
    #                   top: 0,
    #                   bottom: 0,
    #                   left: 0,
    #                   right:0 
    #                 }
    #               )
  end
  def inspection_record_pdf
    i = 0
    if params[:aircraft].blank? or Aircraft.find(params[:aircraft]).blank?
      redirect_to aircrafts_path(), :flash => { :error => "Invalid aircraft." }
    end
    if params[:trade].blank?
      redirect_to aircrafts_path(), :flash => { :error => "Invalid trade." }
    end
    @parts = Aircraft.find(params[:aircraft]).parts.where(is_inspectable: true).where(trade_cd: params[:trade].to_i)
    puts @parts.count.inspect
    pdf_data = render(
                    pdf: "inspection_record_report",
                    orientation: 'Landscape',
                    template: 'reports/inspection_record_pdf.html.slim',
                    layout: 'layouts/pdf/pdf.html.slim',
                    show_as_html: false,
                    locals: {
                      parts: @parts
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
  def scheduled_inspection
  end
end
