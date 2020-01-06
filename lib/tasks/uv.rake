# frozen_string_literal: true

namespace :uv do
  desc 'Update from Universal Viewer repo, fingerprint the directory, and symlink the thumbprinted directory into place'
  task update: [:environment] do
    src = ENV['UV_SRC'] || '../universalviewer/examples/uv/.'
    dest = ENV['UV_DEST'] || './public/uv-3'
    puts 'Copying over build uv'
    FileUtils.cp_r(src, dest)

    # UV is deployed outside the asset pipeline
    # (see https://github.com/UniversalViewer/universalviewer/issues/481)
    #
    # In the meantime, to bust browser caches we're calculating a unique
    # thumbprint for the UV assets ourselves and adding a symlink to the uv-3 directory
    # from a unique path.
    puts 'Calculate a MD5 thumbprint for the UV assets'
    md5 = `tar cf - public/uv-3 | md5`.strip
    File.open('./public/uv-3/.md5', 'w') { |f| f.puts md5 }

    puts 'Adding a symlink for the thumbprinted directory'
    FileUtils.ln_s('./uv-3', dest + '-' + md5)
  end
end
