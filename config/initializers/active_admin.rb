if defined?(ActiveAdmin)
  require 'active_admin/inputs/filters/select2_multiple_ajax_input'
  require 'active_admin/inputs/filters/select2_tags_ajax_input'
  require 'formtastic/inputs/select2_ajax_input'
  require 'formtastic/inputs/select2_multiple_ajax_input'
  require 'formtastic/inputs/select2_tags_ajax_input'
  require 'formtastic/inputs/color_picker_input'
  require 'formtastic/inputs/json_input'
  require 'formtastic/inputs/jsonb_input'

  ActiveadminSettingsCached.configure do |config|
    config.model_name = 'Setting'
  end

  ActiveAdmin.setup do |config|
    config.logout_link_method = :delete
    config.comments_menu = false
    config.download_links = %i[csv json]
  end
end
