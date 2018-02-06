after_bundle do
  create_initial_rspec

  template "spec/depends.rb.tt"

  gsub_file 'spec/rails_helper.rb', /# Add additional requires below this line. Rails is not loaded until this point!/ do
    "# This has to come first
     require_relative './depends'"
  end

  copy_file "spec/support/acts_as_follower.rb" if apply_followers?
  copy_file "spec/support/additional_groups.rb"
  copy_file "spec/support/capybara.rb"
  copy_file "spec/support/carrier_wave.rb" if apply_upload?
  copy_file "spec/support/ckeditor.rb" if apply_upload?
  copy_file "spec/support/custom_matchers.rb"
  copy_file "spec/support/database_cleaner.rb" if apply_db?
  copy_file "spec/support/devise.rb" if apply_devise?
  copy_file "spec/support/mailer.rb"
  copy_file "spec/support/email.rb"
  copy_file "spec/support/factory_bot.rb" if apply_db?
  copy_file "spec/support/features_helper.rb"
  copy_file "spec/support/job_helpers.rb"
  copy_file "spec/support/sidekiq.rb" if apply_sidekiq?
  copy_file "spec/support/rails_controller_testing.rb"
  copy_file "spec/support/shoulda_matchers.rb"
  copy_file "spec/support/tasks.rb"
  copy_file "spec/support/time_helpers.rb"

  copy_file "spec/controllers/admin/accounts_spec.rb" if apply_aa?

  copy_file "spec/helpers/javascript_helper_spec.rb"
  copy_file "spec/helpers/retina_image_helper_spec.rb"
  copy_file "spec/system/layout_helper_spec.rb"

  empty_directory_with_keep_file "spec/matchers"
end