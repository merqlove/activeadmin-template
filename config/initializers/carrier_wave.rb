CarrierWave.configure do |config|
  config.permissions = 0644

  if Rails.env.test?
    config.enable_processing = false
  end
end

module CarrierWave
  module MiniMagick
    def quality(percentage)
      manipulate! do |img|
        img.quality(percentage.to_s)
        img = yield(img) if block_given?
        img
      end
    end
  end
end