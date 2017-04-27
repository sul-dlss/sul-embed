require 'rails_helper'

describe 'imageX viewer', js: true do
  include PURLFixtures
  let(:purl) { image_purl }
  describe 'viewer behavior' do
    before do
      stub_purl_response_with_fixture(purl)
      visit_iframe_response('fw090jw3474')
    end

    describe 'fullscreen' do
      it 'is enabled in detail perspective and disabled in overview' do
        expect(page).to_not have_css '[data-sul-view-fullscreen][disabled]'
        find('[data-sul-view-perspective="overview"]').click
        expect(page).to have_css '[data-sul-view-fullscreen][disabled]'
      end
    end
    describe 'thumbnail viewer' do
      it 'is closed by default' do
        within '.sul-embed-image-x-thumb-slider-container' do
          expect(page).to have_css '.sul-embed-image-x-thumb-slider-open-close', visible: true
          expect(page).to have_css '.sul-embed-thumb-slider-scroll', visible: true
          expect(page).to have_css '.sul-embed-image-x-thumb-slider', visible: false
        end
        find('.sul-embed-image-x-thumb-slider-open-close').click
        expect(page).to have_css '.sul-embed-image-x-thumb-slider', visible: true
        expect(page).to have_css 'img', count: 36
      end
      describe 'is hidden when in overview' do
        before do
          expect(page).to have_css '.sul-embed-image-x-thumb-slider-container', visible: true
          find('[data-sul-view-perspective="overview"]').click
          expect(page).to have_css '.sul-embed-image-x-thumb-slider-container', visible: false
        end
        it 'reappears when canvas clicked' do
          find('[data-id="https://purl.stanford.edu/fw090jw3474/iiif/canvas/fw090jw3474_2"]').click
          expect(page).to have_css '.sul-embed-image-x-thumb-slider-container', visible: true
        end
        it 'reappears when detail select' do
          find('[data-sul-view-mode="individuals"]').click
          expect(page).to have_css '.sul-embed-image-x-thumb-slider-container', visible: true
        end
      end
      describe 'keyboard controls' do
        it 'navigates left and right' do
          find('.sul-embed-image-x-thumb-slider-open-close').click
          expect(page).to have_css '.active[title="Image 1"]'
          container = find('.sul-embed-container')
          container.native.send_key(:Right)
          expect(page).to have_css '.active[title="Image 2"]'
          container.native.send_key(:Left)
          expect(page).to have_css '.active[title="Image 1"]'
        end
        it 'in overview navigate left/right' do
          find('.sul-embed-image-x-thumb-slider-open-close').click
          expect(page).to have_css '.active[title="Image 1"]'
          find('[data-sul-view-perspective="overview"]').click
          container = find('.sul-embed-container')
          container.native.send_key(:Right)
          expect(page).to have_css '.active[title="Image 2"]'
          container.native.send_key(:Left)
          expect(page).to have_css '.active[title="Image 1"]'
        end
        it 'with closed thumb slider' do
          find('.sul-embed-image-x-thumb-slider-open-close').click
          expect(page).to have_css '.active[title="Image 1"]'
          find('.sul-embed-image-x-thumb-slider-open-close').click
          expect(page).to have_css '.sul-embed-image-x-thumb-slider-container',
                                   visible: false
          container = find('.sul-embed-container')
          container.native.send_key(:Right)
          expect(page).to have_css '.active[title="Image 2"]', visible: false
        end
      end
    end

    describe 'Metadata Panel' do
      context 'with multiple images' do
        it 'inlcudes IIIF drag-and-drop text that indicates there is only one image' do
          toggle_metadata_panel

          within('.sul-embed-metadata-panel') do
            expect(page).to have_css('dd', text: /Drag icon to open these images in a/)
          end
        end

        it 'includes an image that links to the PURL with a manifest parameter' do
          toggle_metadata_panel
          purl_url = 'https://purl.stanford.edu/fw090jw3474'

          link = page.find('a.sul-embed-image-x-iiif-drag-and-drop-link')
          expect(link['href']).to match(%r{^#{purl_url}\?manifest=#{purl_url}/iiif/manifest$})
        end

        it 'has a links with _parent targets' do
          toggle_metadata_panel

          within('.sul-embed-metadata-panel') do
            expect(page).to have_css('a.sul-embed-image-x-iiif-drag-and-drop-link[target="_parent"]')
            expect(page).to have_css('.sul-embed-iiif-instruction a[target="_parent"]')
          end
        end
      end

      context 'with a single image' do
        let(:purl) { image_no_size_purl }

        it 'inlcudes IIIF drag-and-drop text that indicates there is more than one image' do
          toggle_metadata_panel

          within('.sul-embed-metadata-panel') do
            expect(page).to have_css('dd', text: /Drag icon to open this image in a/)
          end
        end
      end
    end

    describe 'Download panel' do
      it 'includes proper attributes for _blank target download links' do
        toggle_download_panel

        within('.sul-embed-download-panel') do
          expect(page).to have_css('.download-link', visible: true, count: 6)
          links = page.all('.download-link')

          links.each do |link|
            expect(link['target']).to eq '_blank'
            expect(link['rel']).to eq 'noopener noreferrer'
          end
        end
      end
    end
  end

  describe 'fullscreen toggle' do
    before { stub_purl_response_with_fixture(purl) }
    context 'by default' do
      before { visit_iframe_response('fw090jw3474') }
      it 'is visible' do
        expect(page).to have_css('[data-sul-view-fullscreen]', visible: true)
      end
    end

    context 'when the fullheight option is set' do
      before { visit_iframe_response('fw090jw3474', fullheight: 'true') }
      it 'is hidden' do
        expect(page).to have_css('[data-sul-view-fullscreen]', visible: false)
      end
    end
  end
end
