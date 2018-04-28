require 'rails_helper'

describe 'UV', type: :feature, js: true do
  include PURLFixtures
  let(:request) { Embed::Request.new(url: 'https://purl.stanford.edu/ab123cd4567') }
  describe 'basic use cases' do
    before do
      stub_purl_response_with_fixture(image_with_pdf_purl)
    end
    describe 'share/embed' do
      context 'when in iframe response' do
        it 'has an embeddable iframe' do
          visit_iframe_response('bb023ts9016')
          find('button.share').click
          expect(page).to have_css '.embedView', visible: true
          expect(find('.code').value).to match(
            %r{<iframe src="http:\/\/127.0.0.1:\d+\/iframe\?url=https:\/\/purl.stanford.edu\/bb023ts9016" width="560" height="420" allowfullscreen frameborder="0"><\/iframe>}
          )
        end
      end
      context 'when in embedded context' do
        it 'has an embeddable iframe' do
          pending 'fails to get context from iframe'
          visit_sandbox
          fill_in_default_sandbox_form('bb023ts9016')
          click_button 'Embed'
          within_frame(0) do
            find('button.share').trigger(:click) # When in the iFrame `#click` doesn't work
            page.save_and_open_screenshot
            expect(page).to have_css '.embedView', visible: true
            expect(find('.code').value).to match(
              %r{<iframe src="http:\/\/127.0.0.1:\d+\/iframe\?url=https:\/\/purl.stanford.edu\/bb023ts9016" width="560" height="420" allowfullscreen frameborder="0"><\/iframe>}
            )
          end
        end
      end
    end
  end
end
