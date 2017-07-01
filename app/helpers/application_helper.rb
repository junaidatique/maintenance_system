module ApplicationHelper
  def display_date(input_date)
    unless input_date.blank?
      return input_date.strftime("%d %B %Y")
    end
  end
end
