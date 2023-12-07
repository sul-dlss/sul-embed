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
      end
    end

    private

    attr_reader :resources

    def file_contents
      resources.flat_map(&:files)
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
  end
end
