class BaseUploader < CarrierWave::Uploader::Base
  # include CarrierWave::MimeTypes

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def size_range
    0...200.megabytes
  end

  def filename
    "#{secure_token(12)}.#{file.extension}" if original_filename.present?
  end

  def secure_token(length=16)
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.hex(length/2))
  end

  # process :set_content_type

  # def remove!
  #   super
  # rescue Fog::Storage::OpenStack::NotFound,
  #   Excon::Error::ServiceUnavailable,
  #   Excon::Error::InternalServerError
  #   # ignored
  # end
end
