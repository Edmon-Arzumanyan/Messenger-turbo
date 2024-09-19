module ApplicationHelper
  def flash_alert_class(type)
    case type
    when 'success' then 'text-green-900 bg-green-500'
    when 'notice' then 'text-green-900 bg-green-500'
    when 'danger' then 'text-red-900 bg-red-300 '
    when 'alert' then 'text-red-900 bg-red-300 '
    end
  end
end
