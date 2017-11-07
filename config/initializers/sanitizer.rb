Rails::Html::Sanitizer.white_list_sanitizer.allowed_tags.merge(['table', 'tr', 'td', 'thead', 'tbody'])
Rails::Html::Sanitizer.white_list_sanitizer.allowed_attributes.merge(['id', 'style','contenteditable', 'border', 'colspan'])
