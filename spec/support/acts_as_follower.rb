RSpec.configure do |config|
  config.before(:suite) do
    ActsAsFollower.custom_parent_classes = [ApplicationRecord]
  end
end