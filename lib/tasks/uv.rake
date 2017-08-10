namespace :uv do
  desc 'Update from Universal Viewer repo'
  task :update do
    src = ENV['UV_SRC'] || '../universalviewer/examples/uv/.'
    dest = ENV['UV_DEST'] || './public/uv-3'
    puts 'Copying over build uv'
    FileUtils.cp_r(src, dest)
  end
end
