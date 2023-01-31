# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::HierarchicalContents do
  include PurlFixtures

  describe '#contents' do
    before { stub_purl_response_with_fixture(hierarchical_file_purl) }

    let(:root_dir) { described_class.contents(resources) }
    let(:resources) { Embed::Purl.new('12345').contents }

    it 'returns root ResourceDir' do
      expect(root_dir).to be_an Embed::Purl::ResourceDir
      expect(root_dir.title).to eq ''
      expect(root_dir.files.count).to eq 1
      file1 = root_dir.files.first
      expect(file1).to be_an Embed::Purl::ResourceFile
      expect(file1.title).to eq 'Title_of_the_PDF.pdf'
      expect(file1.index).to eq 1
      expect(root_dir.dirs.count).to eq 1
      dir1 = root_dir.dirs.first
      expect(dir1.title).to eq 'dir1'
      expect(dir1.files.count).to eq 0
      expect(dir1.dirs.count).to eq 1
      dir2 = dir1.dirs.first
      expect(dir2.title).to eq 'dir2'
      expect(dir2.dirs.count).to eq 0
      expect(dir2.files.count).to eq 1
      file2 = dir2.files.first
      expect(file2.title).to eq 'dir1/dir2/Title_of_2_PDF.pdf'
    end
  end
end
