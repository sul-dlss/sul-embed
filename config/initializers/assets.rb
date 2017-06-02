Rails.application.config.assets.precompile += Dir.glob(Rails.root + 'app' + 'assets' + 'javascripts' + '*.js').map { |x| File.basename(x) }
Rails.application.config.assets.precompile += Dir.glob(Rails.root + 'app' + 'assets' + 'stylesheets' + '*.scss*').map { |x| File.basename(x) }
