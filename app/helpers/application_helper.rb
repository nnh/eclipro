module ApplicationHelper
  def model_errors(object)
    content_tag(:div, class: 'panel panel-danger') do
      concat(content_tag(:div, class: 'panel-heading') do
        concat(content_tag(:h4, class: 'panel-title') do
          concat t('.error_message', count: object.errors.count)
        end)
      end)
      concat(content_tag(:div, class: 'panel-body') do
        concat(content_tag(:ul) do
          object.errors.full_messages.each do |msg|
            concat content_tag(:li, msg)
          end
        end)
      end)
    end
  end

  def flash_type(key)
    case key
      when 'notice' then 'success'
      when 'alert' then 'danger'
      when 'warning' then 'warning'
    end
  end
end
