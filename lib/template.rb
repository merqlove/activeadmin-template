if apply_capistrano?
  empty_directory_with_keep_file "lib/capistrano/tasks"
  copy_file "lib/capistrano/tasks/dotenv.rb"
  copy_file "lib/capistrano/tasks/puma.rb"
end

if apply_aa?
  copy_file('lib/active_admin/inputs/filters/select2_multiple_ajax_input.rb')
  copy_file('lib/active_admin/inputs/filters/select2_tags_ajax_input.rb') if apply_tags?
  copy_file('lib/formtastic/inputs/color_picker_input.rb')
  copy_file('lib/formtastic/inputs/select2_ajax_input.rb')
  copy_file('lib/formtastic/inputs/select2_multiple_ajax_input.rb')
  copy_file('lib/formtastic/inputs/select2_tags_ajax_input.rb') if apply_tags?
end

copy_file "lib/tasks/auto_annotate_models.rake"
copy_file "lib/tasks/coverage.rake"
