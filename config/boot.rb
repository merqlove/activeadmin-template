gsub_file "config/application.rb",
          "# config.time_zone = 'Central Time (US & Canada)'",
          'config.time_zone = "Moscow"'

insert_into_file "config/boot.rb",
                 %Q(require "bootsnap/setup"\n),
                 :after => %r{bundler/setup.*$\n}
