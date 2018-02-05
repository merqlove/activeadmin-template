module StoreImageDimensions
  extend ActiveSupport::Concern

  included do
    process :store_dimensions
  end

  def store_dimensions
    if file && model
      model.width, model.height = ::MiniMagick::Image.open(file.file)[:dimensions]
    end
  end
end