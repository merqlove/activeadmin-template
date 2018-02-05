class BaseImageUploader < BaseUploader
  include CarrierWave::MiniMagick
  include StoreImageDimensions

  process quality: 85

  def size_range
    0...20.megabytes
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end
end
