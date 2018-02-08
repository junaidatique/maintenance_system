module ApplicationHelper
  def display_date(input_date)
    unless input_date.blank?
      return input_date.strftime("%d %B %Y")
    end
  end
  def cur_time()
    return "#{Time.zone.now.strftime("%H:%M %p")}"
  end
  def cur_date_mongo()
    return "#{Time.zone.now.strftime("%Y-%m-%d")}"
  end
end
