# frozen_string_literal: true

class FileComponent < ViewComponent::Base
  def initialize(viewer:)
    @viewer = viewer
  end

  attr_reader :viewer

  delegate :purl_object, to: :viewer
  delegate :citation_only?, to: :purl_object

  def message
    viewer.authorization.message
  end

  # If this method is false, then display the "content not available" banner
  # We exclude the embargoed state, because we prefer to show the embargo banner and we don't want two banners
  def display_not_available_banner?
    citation_only? && message.blank?
  end

  # Display of zebra stripes for remaining space depends on number of rows displayed
  def display_row_count(hierarchical_contents)
    counter = 0
    # A resource directory can have both directories at the top level
    # as well as files. We start with the directories.
    hierarchical_contents.dirs.each do |entry|
      # A row is displayed for the directory name, otherwise no row is displayed
      counter += 1 if entry.title.present?
      # Each file in a directory gets its own row for display
      counter += entry.files.size

      # If entry has no directories, we are done
      next if entry.dirs.empty?

      # For each directory, we can calculate the number of rows to display
      dir_count = display_row_count(entry)
      counter += dir_count
    end

    # We also want to add the number of files at the directory top level
    counter += hierarchical_contents.files.size
    counter
  end

  def stripes_class(hierarchical_contents)
    display_row_count(hierarchical_contents).odd? ? 'odd' : 'even'
  end
end
