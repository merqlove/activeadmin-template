copy_file "db/migrate/20182901212022_create_attachments.rb" if apply_upload?

if apply_aa?
  after_bundle do
    gsub_file 'db/seeds.rb',
              /User\.create!\(\:email/,
              'User.create!(:role => 2, :login => "admin", :email'
  end
end