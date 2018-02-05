# frozen_string_literal: true

module TagListConcern
  extend ActiveSupport::Concern

  included do
    attribute :tag_list
  end

  def tag_list
    object&.tag_list&.join(', ')
  end
end
