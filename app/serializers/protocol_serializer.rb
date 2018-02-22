class ProtocolSerializer < ActiveModel::Serializer
  attributes :id, :title, :my_role, :principal_investigator, :status, :version,
             :show_url, :export_pdf_url, :export_docx_url, :clone_url, :section_url

  def my_role
    object.my_role(@instance_options[:user])
  end

  def principal_investigator
    object.participations.principal_investigator.first.user.name
  end

  def status
    object.finalized? ? "#{object.status_i18n} - #{object.finalized_date}" : object.status_i18n
  end

  def show_url
    Rails.application.routes.url_helpers.protocol_path(object)
  end

  def export_pdf_url
    object.finalized? ? Rails.application.routes.url_helpers.export_protocol_path(object, format: :pdf) : ''
  end

  def export_docx_url
    object.finalized? ? Rails.application.routes.url_helpers.export_protocol_path(object, format: :docx) : ''
  end

  def clone_url
    Rails.application.routes.url_helpers.clone_protocol_path(object)
  end

  def section_url
    Rails.application.routes.url_helpers.protocol_content_path(object, object.contents.first, anchor: :sections)
  end
end
