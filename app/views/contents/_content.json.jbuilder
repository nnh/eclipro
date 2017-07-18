json.extract! content, :id, :protocol_id, :section_id, :body, :status, :created_at, :updated_at
json.url content_url(content, format: :json)
