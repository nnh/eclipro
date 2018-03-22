if Rails.env.production?
  Paperclip::Attachment.default_options.update({
    storage: :s3,
    s3_permissions: :private,
    s3_credentials: {
      bucket: ENV.fetch('S3_BUCKET_NAME'),
      access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID'),
      secret_access_key: ENV.fetch('AWS_SECRET_KEY_ID'),
      s3_region: ENV.fetch('AWS_REGION')
    },
    s3_host_name: ENV.fetch('S3_HOST_NAME'),
    url: ':s3_domain_url',
    path: '/:class/:attachment/:id_partition/:filename'
  })
else
  Paperclip::Attachment.default_options[:path] = ":rails_root/public/system/:id_partition/:filename"
  Paperclip::Attachment.default_options[:url] = "http://localhost:3000/system/:id_partition/:filename"
  Paperclip::Attachment.default_options[:use_timestamp] = false
end

if Rails.env.test?
  Paperclip::Attachment.default_options[:url] = ":rails_root/public/system/:id_partition/:filename"
end
