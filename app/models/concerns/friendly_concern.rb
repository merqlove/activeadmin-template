# frozen_string_literal: true

module FriendlyConcern
  extend ActiveSupport::Concern

  included do
    attributes :id
  end

  def id
    object.friendly_id
  end
end