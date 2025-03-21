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

  before do
    allow(Embed::Purl).to receive(:find).and_return(purl)
    visit_iframe_response
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
        expect(page).to have_content('Image of media (1 of 1)')
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
