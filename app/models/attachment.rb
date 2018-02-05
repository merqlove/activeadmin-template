# http://www.opendrops.com/rails/2015/01/30/rails-globalid-polymorhphic-select-form/
class Attachment < ApplicationRecord
  belongs_to :parent, polymorphic: true
  before_save :update_asset_attributes

  def filename
    File.basename(data.url)
  end

  def to_s
    data_file_name
  end

  private

  def update_asset_attributes
    return unless data.present? && self.changed?
    self.checksum = ::Digest::MD5.file(data.file.path).hexdigest
    self.data_file_size = data.file.size
  end
end
