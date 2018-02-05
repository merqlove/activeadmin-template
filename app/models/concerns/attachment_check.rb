# frozen_string_literal: true

module AttachmentCheck
  extend ActiveSupport::Concern

  def false_destroy?(attrs)
    attrs['data'].blank? && attrs['_destroy'] == '0'
  end
end
