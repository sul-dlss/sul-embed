# frozen_string_literal: true

module Embed
  class HierarchicalContents
    def self.contents(resources)
      new(resources).contents
    end

    def initialize(resources)
      @resources = resources
    end

    def contents
      Purl::ResourceDir.new('', [], []).tap do |root_dir|
        file_contents.each { |file| add_to_hierarchy(file, root_dir) }
        add_index(root_dir, 0)
      end
    end

    private

    attr_reader :resources

    def file_contents
      resources.flat_map(&:files).map { |file| HierarchicalFile.new(file) }
    end

    def add_to_hierarchy(file, root_directory)
      paths = file.title.split('/')
      paths.pop

      directory = directory_for(paths, root_directory)
      directory.files << file
    end

    def directory_for(paths, directory)
      return directory if paths.empty?

      path = paths.shift
      child_directory = directory.dirs.find { |dir| dir.title == path }
      unless child_directory
        child_directory = Purl::ResourceDir.new(path, [], [])
        directory.dirs << child_directory
      end

      return child_directory if paths.empty?

      directory_for(paths, child_directory)
    end

    def add_index(directory, index)
      directory.files.each do |file|
        index += 1
        file.index = index
      end

      directory.dirs.each do |dir|
        index = add_index(dir, index)
      end

      index
    end
  end
end
