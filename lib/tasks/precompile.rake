# frozen_string_literal: true

# See https://github.com/rails/rails/issues/43906#issuecomment-1099992310
Rake::Task['assets:precompile'].enhance ['yarn:install']
