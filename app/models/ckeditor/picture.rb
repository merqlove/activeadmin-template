class Ckeditor::Picture < Attachment
  include CkeditorAssets
  include DynamicDataUrl

  mount_uploader :data, CkeditorPictureUploader, mount_on: :data_file_name

  def url_content
    url(:content)
  end
end
