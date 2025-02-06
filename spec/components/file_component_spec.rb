# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FileComponent, type: :component do
  let(:request) do
    Embed::Request.new(url: 'http://purl.stanford.edu/abc123', min_files_to_search: 1, new_viewer: 'true')
  end
  let(:viewer) { Embed::Viewer::File.new(request) }
  let(:purl) { build(:purl, contents: resources) }
  let(:resources) { [build(:resource, :video, files: [build(:resource_file, :video, :stanford_only, label: 'Second Video')])] }

  before do
    allow(Embed::Purl).to receive(:find).and_return(purl)
    render_inline(described_class.new(viewer:))
  end

  it 'returns html that has a body wrapped in a container' do
    # visible :all because we display:none the container until we've loaded the CSS.
    expect(page).to have_css 'div.sul-embed-container', visible: :all
    expect(page).to have_content 'Search this list'
  end

  context 'when a version id is supplied' do
    let(:request) do
      Embed::Request.new(url: 'http://purl.stanford.edu/bc123df456/version/1')
    end
    let(:purl) { build(:purl, contents: resources, druid: 'bc123df456', version_id: '1') }
    let(:resources) { [build(:resource, :file, druid: 'bc123df456', files: [build(:resource_file, label: 'A File')])] }

    it 'returns a versioned stacks url' do
      link = page.find('tr[data-tree-role="leaf"] a', match: :first, visible: :all)
      expect(link['href']).to eq('https://stacks.stanford.edu/v2/file/bc123df4567/version/1/data.zip')
    end
  end

  context 'with multiple files' do
    let(:resources) do
      [
        build(:resource, :file,
              files: [
                build(:resource_file, :document, size: 12_345),
                build(:resource_file, :document, size: 12_346)
              ])
      ]
    end

    it 'returns a table of files' do
      # visible :all because we display:none the container until we've loaded the CSS.
      expect(page).to have_css 'a[download]', visible: :all, text: 'Download'
    end

    it 'have the appropriate attributes for being _blank' do
      expect(page).to have_css('td[role="gridcell"] a[target="_blank"][rel="noopener noreferrer"]', visible: :all)
    end
  end

  context 'when file size is zero' do
    let(:resources) do
      [build(:resource, :image, files: [build(:resource_file, :image, size: 0)])]
    end

    it 'displays Download as the link text' do
      expect(page).to have_css 'a[download]', visible: :all, text: /Download$/
    end
  end

  describe 'embargo/Stanford only' do
    let(:purl) { build(:purl, :embargoed_stanford, contents: resources) }
    let(:resources) { [build(:resource, :file, files: [build(:resource_file, :document, :stanford_only, filename: 'Title of the PDF.pdf')])] }

    it 'adds a Stanford specific embargo message with links still present' do
      expect(page).to have_css('.sul-embed-embargo-message', visible: :all, text: 'Access is restricted to Stanford-affiliated patrons until 21-Dec-2053')
      expect(page).to have_css('tr[data-tree-role="leaf"] a[href="https://stacks.stanford.edu/file/druid:bc123df4567/Title%20of%20the%20PDF.pdf"]', visible: :all)
    end

    it 'includes an element with a stanford icon class (with screen reader text)' do
      expect(page).to have_css(
        'tr[data-tree-role="leaf"] .sul-embed-stanford-only-text .sul-embed-text-hide',
        visible: :all,
        text: 'Stanford only'
      )
    end
  end

  describe 'embargoed to world' do
    let(:purl) { build(:purl, :embargoed, contents: resources) }

    it 'adds a generalized embargo message and no links are present' do
      expect(page).to have_css('.sul-embed-embargo-message', visible: :all, text: 'Access is restricted until 21-Dec-2053')
      # FIXME: this is a bad spec as it's not checking for visibility false
      expect(page).to have_no_link
    end
  end

  describe 'location restricted' do
    let(:resources) { [build(:resource, :video, files: [build(:resource_file, :video, :location_restricted, label: 'Second Video')])] }

    it 'includes text indicating the file is location restricted' do
      expect(page).to have_css('tr[data-tree-role="leaf"] .sul-embed-location-restricted-text', visible: :all, text: '(Restricted)')
    end
  end

  describe 'media list' do
    let(:resources) { [build(:resource, :video, files: [build(:resource_file, :video, filename:)])] }

    context 'with a normal filename' do
      let(:filename) { 'Title_of_the_PDF.pdf' }

      it 'leaves correctly formatted filenames alone' do
        link = page.find('tr[data-tree-role="leaf"] a', match: :first, visible: :all)
        expect(link['href']).to eq('https://stacks.stanford.edu/file/druid:bc123df4567/Title_of_the_PDF.pdf')
      end
    end

    context 'with a wonky filename' do
      let(:filename) { '#Title of the PDF.pdf' }

      it 'encodes them' do
        link = page.find('tr[data-tree-role="leaf"] a', match: :first, visible: :all)
        expect(link['href']).to eq('https://stacks.stanford.edu/file/druid:bc123df4567/%23Title%20of%20the%20PDF.pdf')
      end
    end
  end
end
