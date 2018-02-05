RSpec.configure do |config|
  config.before(:suite) do
    [
      [CkeditorAttachmentFileUploader, 'editor'],
      [CkeditorPictureUploader, 'pictures']
    ].each do |u|
      next if u[0].anonymous?

      u[0].class_eval do
        def cache_dir
          "#{Rails.root}/spec/uploads/tmp"
        end

        def store_dir
          "#{Rails.root}/spec/uploads/editor/#{u[1]}/#{model.id}"
        end
      end
    end
  end
end