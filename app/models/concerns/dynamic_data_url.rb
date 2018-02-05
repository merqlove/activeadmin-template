# frozen_string_literal: true

module DynamicDataUrl
  extend ActiveSupport::Concern

  def copy_data_url=(parent)
    return unless parent&.data&.file&.exists?

    if parent.data_url&.include?('http')
      self.remote_data_url = parent.data_url
    else
      self.data = parent.data.file
    end
  end

  def recreate_asset!
    return unless data

    if data&._storage.equal?(CarrierWave::Storage::File)
      data.recreate_versions! if data.file.present?
    elsif data_url&.include?('http')
      self.remote_data_url = data_url
      save!
    end
  end
end
