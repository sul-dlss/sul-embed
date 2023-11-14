# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'embed this panel', :js do
  include PurlFixtures

  let(:iframe_options) { {} }

  before do
    stub_request(:get, 'https://purl.stanford.edu/ab123cd4567.xml')
      .to_return(status: 200, body: spec_fixture)
    visit_iframe_response('ab123cd4567', **iframe_options)
  end

  describe 'embed code' do
    let(:spec_fixture) { file_purl }

    it 'includes the allowfullscreen no-scrolling, no-border, and no margin/padding attributes' do
      page.find('[data-sul-embed-toggle="sul-embed-embed-this-panel"]', match: :first).click
      expect(page.find('.sul-embed-embed-this-panel textarea', visible: :all).value).to match(/<iframe.*frameborder="0"/m)
      expect(page.find('.sul-embed-embed-this-panel textarea', visible: :all).value).to match(/<iframe.*marginwidth="0"/m)
      expect(page.find('.sul-embed-embed-this-panel textarea', visible: :all).value).to match(/<iframe.*marginheight="0"/m)
      expect(page.find('.sul-embed-embed-this-panel textarea', visible: :all).value).to match(/<iframe.*scrolling="no"/m)
      expect(page.find('.sul-embed-embed-this-panel textarea', visible: :all).value).to match(/<iframe.*allowfullscreen/m)
    end

    it 'includes height and width attributes' do
      page.find('[data-sul-embed-toggle="sul-embed-embed-this-panel"]', match: :first).click
      expect(page.find('.sul-embed-embed-this-panel textarea', visible: :all).value).to match(/<iframe.*height="190px"/m)
      expect(page.find('.sul-embed-embed-this-panel textarea', visible: :all).value).to match(/<iframe.*width="100%"/m)
    end

    it 'includes the viewer\'s iframe title' do
      page.find('[data-sul-embed-toggle="sul-embed-embed-this-panel"]', match: :first).click
      expect(page.find('.sul-embed-embed-this-panel textarea', visible: :all).value).to match('title="File viewer"')
    end
  end

  describe 'file objects' do
    let(:spec_fixture) { file_purl }

    it 'are present after a user clicks the button' do
      expect(page).to have_css('.sul-embed-embed-this-panel', visible: :hidden)
      page.find('[data-sul-embed-toggle="sul-embed-embed-this-panel"]', match: :first).click
      expect(page).to have_css('.sul-embed-embed-this-panel', visible: :all)
      page.find('[data-sul-embed-toggle="sul-embed-embed-this-panel"]', match: :first).click
      expect(page).to have_css('.sul-embed-embed-this-panel', visible: :hidden)
    end

    it 'update the textarea when the checkboxes are selected' do
      page.find('[data-sul-embed-toggle="sul-embed-embed-this-panel"]', match: :first).click
      expect(page.find('.sul-embed-embed-this-panel textarea').value).not_to match(/&hide_search=true/)
      page.find("input#sul-embed-embed-search[type='checkbox']").click
      expect(page.find('.sul-embed-embed-this-panel textarea').value).to match(/&hide_search=true/)
      page.find("input#sul-embed-embed-search[type='checkbox']").click
      expect(page.find('.sul-embed-embed-this-panel textarea').value).not_to match(/&hide_search=true/)
    end
  end

  describe 'Customization Options' do
    let(:spec_fixture) { file_purl }

    context 'with an uncustomized request' do
      it 'defaults to having the option checked' do
        page.find('[data-sul-embed-toggle="sul-embed-embed-this-panel"]', match: :first).click
        expect(page.find('#sul-embed-embed-title')).to be_checked
      end
    end

    context 'with a customized request' do
      let(:iframe_options) { { hide_title: true } }

      it "defaults to the options from the current viewer's request" do
        page.find('[data-sul-embed-toggle="sul-embed-embed-this-panel"]', match: :first).click
        expect(page.find('#sul-embed-embed-title')).not_to be_checked
      end
    end
  end
end
