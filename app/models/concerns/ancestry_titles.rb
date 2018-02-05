# frozen_string_literal: true

module AncestryTitles
  extend ActiveSupport::Concern

  included do
    before_save :cache_ancestry
  end

  def parent_list
    self.class.order(:titles_depth_cache).where.not(id: id).map { |c| [ '-' * c.depth + ' ' + c.title, c.id ] }
  end

  def cache_ancestry
    self.titles_depth_cache = path.pluck(:title).join('/')
  end
end