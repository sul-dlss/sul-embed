# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'embed this panel', :js do
  let(:iframe_options) { {} }
  let(:purl) do
    build(:purl, :file,
          contents: [build(:resource, files: [build(:resource_file, :document, label: 'File1 Label')])])
  end

  before do
    allow(Embed::Purl).to receive(:find).and_return(purl)
    visit_iframe_response('ab123cd4567', **iframe_options)
    click_on 'Share & download'
    click_on 'Share'
  end

  describe 'embed code' do
    it 'creates an iframe with appropriate options' do
      within '.sul-embed-embed-this-form' do
        textarea_value = page.find('textarea').value
        expect(textarea_value).to match(/<iframe.*frameborder="0"/m)
        expect(textarea_value).to match(/<iframe.*marginwidth="0"/m)
        expect(textarea_value).to match(/<iframe.*marginheight="0"/m)
        expect(textarea_value).to match(/<iframe.*scrolling="no"/m)
        expect(textarea_value).to match(/<iframe.*allowfullscreen/m)
        expect(textarea_value).to match(/<iframe.*height="500px" width="100%"/m)
        expect(textarea_value).to match('title="File viewer: Title of the object"')

        expect(page).to have_checked_field('embed')

        expect(textarea_value).not_to match(/&hide_search=true/)
        uncheck 'add search box'
        textarea_value = page.find('textarea').value
        expect(textarea_value).to match(/&hide_search=true/)
        check 'add search box'
        textarea_value = page.find('textarea').value
        expect(textarea_value).not_to match(/&hide_search=true/)
      end
    end
  end

  context 'with a customized request' do
    let(:iframe_options) { { hide_title: true } }

    it "defaults to the options from the current viewer's request" do
      textarea_value = page.find('textarea').value

      expect(textarea_value).to match(/&hide_title=true/)
      expect(page).to have_no_checked_field('title (Title of the object)')
    end
  end
end
