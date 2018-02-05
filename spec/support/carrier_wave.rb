require 'carrierwave/test/matchers'

RSpec.configure do |config|
  config.include CarrierWave::Test::Matchers, file_path: /spec\/uploaders/
  config.include RSpec::Rails::RequestExampleGroup, file_path: /spec\/uploaders/

  config.before(:suite) do
    [].each do |klass|
      klass.class_eval do
        def cache_dir
          "#{Rails.root}/spec/uploads/tmp"
        end

        def store_dir
          "#{Rails.root}/spec/uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
        end
      end
    end
  end
  config.after(:each) do
    next unless RSpec.current_example.metadata[:upload]
    FileUtils.rm_rf(Dir["#{Rails.root}/spec/uploads"])
  end
end
