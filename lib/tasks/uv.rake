namespace :uv do
  desc 'Update from Universal Viewer repo'
  task :update do
    src = ENV['UV_SRC'] || '../universalviewer/examples/uv/.'
    dest = ENV['UV_DEST'] || './public/uv-3'
    puts 'Copying over build uv'
    FileUtils.cp_r(src, dest)

    puts 'Rename and format extension-dependencies'
    ##
    # I have no idea but see:
    # https://github.com/sul-dlss/sul-embed/commit/d1b31107a7f09ed296e3551cfc3bb02f6f94980b
    # We are renaming the files to drop the js extensions, but adding the js
    # extensions that are referenced in the files. ¯\_(ツ)_/¯
    Dir.glob(File.join(dest, 'lib', '*-extension-dependencies.js')).each do |ext_dep|
      without = ext_dep.gsub('.js', '')
      FileUtils.mv(ext_dep, without)
      text = File.read(without)
      new_text = text.gsub('\']', '.js\']')
      new_text = new_text.gsub('\',', '.js\',')
      File.open(without, 'w') { |f| f.puts new_text }
    end
  end
end
