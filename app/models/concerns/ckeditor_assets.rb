# frozen_string_literal: true

require 'ckeditor/orm/base'

module CkeditorAssets
  extend ActiveSupport::Concern
  include Ckeditor::Orm::Base::AssetBase::InstanceMethods

  included do
    delegate :url, :current_path, :content_type, to: :data

    validates :data, presence: true

    alias_method :assetable=, :parent=
    alias_method :assetable,  :parent
  end
end
