# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Media viewer', :js do
  let(:purl) do
    build(:purl, :video, contents: [
            build(:resource, :video, files: [build(:media_file, :video, :view_location_restricted, label: 'First Video')]),
            build(:resource, :video, files: [build(:media_file, :video, :stanford_only, label: 'Second Video')]),
            build(:resource, :file),
            build(:resource, :video, files: [build(:media_file, :video, :world_downloadable)])
          ])
  end

  let(:query) { {} }

  before do
    allow(Embed::Purl).to receive(:find).and_return(purl)
    visit iframe_path(url: "#{Settings.purl_url}/ignored", **query)
  end

  context 'with multiple A/V files' do
    # The ajax request that displays the video does not fire in this context
    # so we are checking for a non-visible video in the first case (even though it should be visible)

    # the object-content panel and tab are selected by default
    it 'selects the object-content tab by default' do
      within '.vert-tabs' do
        expect(page).to have_css('button[aria-selected="true"][aria-controls="object-content"]')
      end
    end

    it 'displays the viewer' do
      within 'aside.open' do
        # object-content is the default tab; the other 2 are present but hidden
        expect(find_by_id('object-content')).to be_visible
        expect(page).to have_css('#about', visible: :hidden)
        expect(page).to have_css('#rights', visible: :hidden)

        expect(page).to have_css('.media-thumb', count: 3)
        # It indicates that one of the files is Stanford only
        expect(page).to have_css('.sul-embed-thumb-stanford-only', text: /Second Video$/)
        # One is restricted
        expect(page).to have_css('.sul-embed-location-restricted-text', text: '(Restricted)')
        expect(page).to have_css('.media-thumb', text: '(Restricted) First Video')

        # switch to the "Information" tab
        click_on 'Information'
        expect(find_by_id('about')).to be_visible
        expect(page).to have_css('#object-content', visible: :hidden)

        # switch to the "Rights" tab
        click_on 'Rights'
        expect(find_by_id('rights')).to be_visible
      end

      click_on 'Toggle sidebar'
      expect(page).to have_no_css 'aside.open'

      expect(page).to have_css('video', visible: :all)
    end
  end

  context 'with a previewable file within a media object' do
    let(:purl) do
      build(:purl, :video,
            contents: [
              build(:resource, :video),
              build(:resource, :image, files: [build(:media_file, :image, label: 'Image of media (1 of 1)')])
            ])
    end

    it 'includes a previewable image as a top level object' do
      expect(page).to have_css('div .osd', visible: :hidden)

      within 'aside.open' do
        click_on 'Content'

        # Setting blank alt text apparently makes the component invisible in copybara
        expect(page).to have_css('.square-icon', visible: :all)
        expect(page).to have_text('Image of media (1 of 1)')
      end
    end
  end

  context 'with a PDF within a media object' do
    let(:purl) do
      build(:purl, :video,
            contents: [
              build(:resource, :video),
              build(:resource, :media_pdf)
            ])
    end

    it 'includes the PDF as a top level object using the built in PDF viewer' do
      expect(page).to have_css('div .sul-embed-pdf', visible: :hidden)

      within 'aside.open' do
        click_on 'Content'

        expect(page).to have_css('.pdf-thumbnail-icon', visible: :all)
        expect(page).to have_text('Program Notes')
      end
    end
  end

  context 'when a filename is requested' do
    let(:purl) do
      build(:purl, :video,
            contents: [
              build(:resource, :video),
              build(:resource, :media_pdf)
            ])
    end
    let(:query) { { filename: 'program_notes.pdf' } }

    it 'opens on that file rather than the first one' do
      # The PDF is on screen and the video it would otherwise have opened on is not
      expect(page).to have_css('div .sul-embed-pdf', visible: :visible)
      expect(page).to have_css('[data-media-wrapper-index-value="0"]', visible: :hidden)

      within 'aside.open' do
        click_on 'Content'
        expect(page).to have_css('.media-thumb.active', text: 'Program Notes')
      end
    end

    it 'does not request a page when none was asked for' do
      expect(page).to have_no_css('.sul-embed-pdf[data-pdf-page-value]', visible: :all)
    end

    context 'with a page' do
      let(:query) { { filename: 'program_notes.pdf', page: '4' } }

      it 'passes the page through to the PDF viewer' do
        expect(page).to have_css('.sul-embed-pdf[data-pdf-page-value="4"]', visible: :all)
      end
    end

    context 'when the filename is not on the object' do
      let(:query) { { filename: 'nope.pdf' } }

      it 'falls back to the first resource' do
        expect(page).to have_css('[data-media-wrapper-index-value="0"]', visible: :visible)
        expect(page).to have_css('div .sul-embed-pdf', visible: :hidden)
      end
    end
  end

  context 'with long titles' do
    let(:purl) do
      build(:purl, :video, contents: [
              build(:resource, :video, files: [
                      build(:media_file, :video, :view_location_restricted,
                            label: 'The First Video Has An Overly Long Title, With More Words Than Can Practically Be Displayed')
                    ]),
              build(:resource, :video, files: [build(:media_file, :video, label: '2nd Video Has A Long Title, But Not Too Long')])
            ])
    end

    it 'truncates at 45 characters of combined restriction and title text' do
      within 'aside' do
        click_on 'Content'
        expect(page).to have_css('.media-thumb', text: /^\(Restricted\) The First Video Has An Overly Lo…$/)

        # displays the whole title if it is under the length limit
        expect(page).to have_css('.media-thumb', text: /^2nd Video Has A Long Title, But Not Too Long$/)
      end
    end
  end
end
