class ProtocolSerializer < BaseSerializer
  attributes :id, :title, :my_role, :principal_investigator, :status, :version,
             :show_url, :export_url, :clone_url, :section_url

  def my_role
    object.my_role(@instance_options[:user])
  end

  def status
    object.finalized? ? "#{object.status_i18n} - #{object.finalized_date}" : object.status_i18n
  end

  def show_url
    url_helpers.protocol_path(object)
  end

  def export_url
    object.finalized? ? url_helpers.select_protocol_path(object) : ''
  end

  def clone_url
    url_helpers.clone_protocol_path(object)
  end

  def section_url
    url_helpers.protocol_content_path(object, object.contents.first, anchor: :sections)
  end
end
