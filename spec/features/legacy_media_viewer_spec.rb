# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'The old media viewer', :js do
  let(:purl) do
    build(:purl, :video,
          title: 'stupid dc title of video',
          contents: [
            build(:resource, :video, files: [build(:resource_file, :video, :location_restricted, label: 'First Video', duration: '1:02:03')]),
            build(:resource, :video, files: [build(:resource_file, :video, :stanford_only, label: 'Second Video')]),
            build(:resource, :file, files: [build(:resource_file, :document, :world_downloadable)]),
            build(:resource, :video, files: [build(:resource_file, :video, :world_downloadable)])
          ])
  end
  let(:stub_auth) { nil }

  before do
    allow(Settings.streaming).to receive(:auth_url).and_return('/test_auth_jsonp_endpoint')
    stub_auth
    allow(Embed::Purl).to receive(:find).and_return(purl)
    visit_iframe_response
  end

  it 'renders player in html' do
    expect(page).to have_css('video', visible: :all)
  end

  describe 'footer panels' do
    it 'renders a toggle-able metadata panel' do
      find('button.sul-embed-footer-tool.sul-i-infomation-circle').click
      within '.sul-embed-metadata-panel' do
        expect(page).to have_css '.sul-embed-panel-title', text: 'stupid dc title of video'
      end
    end

    it 'renders a download panel' do
      expect(page).to have_css('.sul-embed-download-panel', visible: :all)

      page.find('button[data-sul-embed-toggle="sul-embed-download-panel"]', visible: true)
      page.find('[data-sul-embed-toggle="sul-embed-download-panel"]', match: :first).click

      expect(page).to have_css('.sul-embed-download-panel', visible: :visible)
      expect(page).to have_css('ul.sul-embed-download-list', count: 1)
      expect(page).to have_css('.sul-embed-download-list li a', visible: :visible, count: 3, text: /^Download/)
    end
  end

  context 'with a single A/V file' do
    let(:purl) do
      build(:purl, :media, contents: [
              build(:resource, :audio, files: [build(:resource_file, :audio, label: 'First Audio', duration: '0:43')])
            ])
    end

    it 'does does not have the thumbnail slider panel' do
      expect(page).to have_css('.sul-embed-container', visible: :visible) # to wait for the viewer to load
      expect(page).not_to have_css('.sul-embed-thumb-slider-container', visible: :visible)
    end
  end

  describe 'Stanford link' do
    context 'when the user can access the file' do
      let(:stub_auth) { StubAuthJsonpEndpoint.set_success! }

      it 'hides the link' do
        expect(page).to have_css('.sul-embed-container', visible: :visible) # to wait for the viewer to load
        expect(page).not_to have_css('.sul-embed-auth-link a', visible: :visible)
        expect(page).not_to have_content 'Restricted media cannot be played in your location.'
      end
    end

    context 'when the user cannot access the file' do
      let(:stub_auth) { StubAuthJsonpEndpoint.set_stanford! }

      it 'shows the Stanford link' do
        expect(page).to have_css('.sul-embed-auth-link a', visible: :visible)
      end
    end
  end

  context 'with multiple A/V files' do
    # The ajax request that displays the video does not fire in this context
    # so we are checking for a non-visible video in the first case (even though it should be visible)
    it 'has a toggle-able thumbnail slider panel' do
      expect(page).to have_css('.sul-embed-thumb-slider-container', visible: :visible)
      expect(page).to have_css('.sul-embed-thumb-slider-open-close', visible: :visible)
      expect(page).to have_css('.sul-embed-thumb-slider[aria-expanded="false"]', visible: :all)
      expect(page).to have_css('.sul-embed-thumb-slider-open-close[aria-expanded="false"]', visible: :visible)
      page.find('.sul-embed-thumb-slider-open-close').click
      expect(page).to have_css('.sul-embed-thumb-slider[aria-expanded="true"]', visible: :visible)
      expect(page).to have_css('.sul-embed-thumb-slider-open-close[aria-expanded="true"]', visible: :visible)
      expect(page).to have_css('[data-slider-object="0"] video', visible: :all)
      expect(page).to have_css('[data-slider-object="1"] video', visible: :all)

      within('.sul-embed-thumb-slider') do
        expect(page).to have_css('.sul-embed-slider-thumb', count: 3)
      end
    end

    it 'has the class indicating Stanford only for stanford restricted files (with screenreader text)' do
      expect(page).not_to have_css('.sul-embed-thumb-slider', visible: :visible)
      page.find('.sul-embed-thumb-slider-open-close').click
      expect(page).to have_css('.sul-embed-thumb-slider', visible: :visible)

      expect(page).to have_css('.sul-embed-thumb-stanford-only', count: 1)
      expect(page).to have_css('.sul-embed-thumb-stanford-only', text: 'Second Video')
      expect(page).to have_css('.sul-embed-thumb-stanford-only .sul-embed-text-hide', text: 'Stanford only', count: 1)
      expect(page).not_to have_css('.sul-embed-thumb-stanford-only', text: 'First Video')
    end
  end

  context 'with a previewable file within a media object' do
    let(:purl) do
      build(:purl, :video,
            contents: [
              build(:resource, :video),
              build(:resource, :image, files: [build(:resource_file, :image, label: 'Image of media (1 of 1)')])
            ])
    end

    it 'includes a previewable image as a top level object' do
      expect(page).to have_css('div img.sul-embed-media-thumb', visible: :all)
    end

    it 'includes a thumb for the previewable image in the thumb slider' do
      expect(page).to have_css('.sul-embed-thumb-slider', visible: :all)
      page.find('.sul-embed-thumb-slider-open-close').click
      expect(page).to have_css('.sul-embed-thumb-slider')
      expect(page).to have_css('.sul-embed-thumb-slider', visible: :visible)

      # Setting blank alt text apparently makes the component invisible in copybara
      expect(page).to have_css('.sul-embed-media-square-icon', visible: :all)
      expect(page).to have_css('.sul-embed-thumb-label', text: 'Image of media (1 of 1)')
    end
  end

  context 'with a location restricted file within a media object' do
    it 'displays the restricted text with the appropriate styling' do
      expect(page).not_to have_css('.sul-embed-thumb-slider', visible: :visible)
      page.find('.sul-embed-thumb-slider-open-close').click
      expect(page).to have_css('.sul-embed-thumb-slider', visible: :visible)

      expect(page).to have_css('.sul-embed-location-restricted-text', text: '(Restricted)', count: 1)
      expect(page).to have_css('.sul-embed-media-slider-thumb', text: '(Restricted) First Video')
    end
  end

  context 'with duration related info' do
    it 'displays available duration in parens after the title (video)' do
      page.find('.sul-embed-thumb-slider-open-close').click
      expect(page).to have_css('.sul-embed-media-slider-thumb', text: 'First Video (1:02:03)')
    end

    it 'displays no duration info after title when there is no duration we can interpret' do
      page.find('.sul-embed-thumb-slider-open-close').click
      expect(page).to have_css('.sul-embed-media-slider-thumb', text: /Second Video$/)
    end

    context 'when duration is not present' do
      let(:purl) do
        build(:purl, :video, contents: [
                build(:resource, :video, files: [build(:resource_file, :video, label: 'First Video', duration: nil)]),
                build(:resource, :video, files: [build(:resource_file, :video, label: 'Second Video', duration: nil)])
              ])
      end

      it 'displays as if there were no duration' do
        page.find('.sul-embed-thumb-slider-open-close').click
        expect(page).to have_css('.sul-embed-media-slider-thumb', text: 'First Video')
      end
    end

    context 'with an audio' do
      let(:purl) do
        build(:purl, :media, contents: [
                build(:resource, :audio, files: [build(:resource_file, :audio, label: 'First Audio', duration: '0:43')]),
                build(:resource, :audio, files: [build(:resource_file, :audio, label: 'Second Audio', duration: nil)])
              ])
      end

      it 'displays available duration in parens after the title' do
        page.find('.sul-embed-thumb-slider-open-close').click
        expect(page).to have_css('.sul-embed-media-slider-thumb', text: 'First Audio (0:43)')
      end

      it 'displays no duration info after title when there is no duration we can interpret' do
        page.find('.sul-embed-thumb-slider-open-close').click
        expect(page).to have_css('.sul-embed-media-slider-thumb', text: 'Second Audio')
      end
    end
  end

  context 'with long titles' do
    let(:purl) do
      build(:purl, :video, contents: [
              build(:resource, :video, files: [
                      build(:resource_file, :video, :location_restricted,
                            label: 'The First Video Has An Overly Long Title, With More Words Than Can Practically Be Displayed',
                            duration: '1:02:03')
                    ]),
              build(:resource, :video, files: [build(:resource_file, :video, label: '2nd Video Has A Long Title, But Not Too Long')])
            ])
    end

    it 'truncates at 45 characters of combined restriction and title text' do
      page.find('.sul-embed-thumb-slider-open-close').click
      expect(page).to have_css('.sul-embed-media-slider-thumb', text: /^\(Restricted\) The First Video Has An Overly Lo… \(1:02:03\)$/)
    end

    it 'displays the whole title if it is under the length limit' do
      page.find('.sul-embed-thumb-slider-open-close').click
      expect(page).to have_css('.sul-embed-media-slider-thumb', text: /^2nd Video Has A Long Title, But Not Too Long$/)
    end
  end
end
