require 'rails_helper'

describe Embed::MetadataPanel do
  let(:purl_object) do
    double(
      'Embed::PURL',
      title: 'The Title of the PURL',
      purl_url: 'https://purl.stanford.edu/abc123',
      use_and_reproduction: '',
      copyright: '2015, Leland Stanford University',
      license: { machine: 'the-license', human: 'The license statement' }
    )
  end
  let(:panel_html) { Capybara.string(described_class.new(purl_object).to_html) }

  describe 'title' do
    it 'renders the title of the purl object in the panel header' do
      expect(panel_html).to have_css('.sul-embed-panel-title', text: 'The Title of the PURL', visible: false)
    end
  end

  describe 'Online link' do
    it 'renders a link to the PURL (dropping protocol for the link text)' do
      expect(panel_html).to have_css('.sul-embed-panel-body dt', text: 'Available online', visible: false)
      link = panel_html.find('dd a', visible: false)
      expect(link['href']).to eq 'https://purl.stanford.edu/abc123'
      expect(link.text).to eq 'purl.stanford.edu/abc123'
    end
  end

  describe 'Pieces of metadata' do
    context 'pieces that do not exist in the data (use_and_reproduction)' do
      it 'does not render' do
        expect(panel_html).to_not have_css('dt', text: 'Use and reproduction', visible: false)
      end
    end

    context 'pieces that do exist in the data (copyright)' do
      it 'does render' do
        expect(panel_html).to have_css('dt', text: 'Copyright', visible: false)
      end
    end

    context 'complex license data' do
      it 'renders with an element classed to display an icon' do
        expect(panel_html).to have_css('dt', text: 'License', visible: false)
        expect(panel_html).to have_css('dd span.sul-embed-license-the-license', visible: false)
        expect(panel_html).to have_css('dd', text: 'The license statement', visible: false)
      end
    end
  end
end
