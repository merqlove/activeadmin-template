# frozen_string_literal: true

module CloneAll
  extend ActiveSupport::Concern

  class_methods do
    def clone_all(query, collection = self)
      return unless query

      transaction do
        collection.where(query).find_each(&:cloning)
      end
    end
  end
end
