# frozen_string_literal: true

require 'rails_helper'

describe 'embed this panel', js: true do
  include PURLFixtures

  let(:iframe_options) { {} }

  before do
    stub_purl_response_with_fixture(spec_fixture)
    visit_iframe_response('ab123cd4567', iframe_options)
  end

  describe 'embed code' do
    let(:spec_fixture) { file_purl }
    it 'includes the allowfullscreen no-scrolling, no-border, and no margin/padding attributes' do
      page.find('[data-sul-embed-toggle="sul-embed-embed-this-panel"]', match: :first).click
      expect(page.find('.sul-embed-embed-this-panel textarea').value).to match(%r{<iframe.*frameborder='0'.*/>}m)
      expect(page.find('.sul-embed-embed-this-panel textarea').value).to match(%r{<iframe.*marginwidth='0'.*/>}m)
      expect(page.find('.sul-embed-embed-this-panel textarea').value).to match(%r{<iframe.*marginheight='0'.*/>}m)
      expect(page.find('.sul-embed-embed-this-panel textarea').value).to match(%r{<iframe.*scrolling='no'.*/>}m)
      expect(page.find('.sul-embed-embed-this-panel textarea').value).to match(/<iframe.*allowfullscreen.*>/m)
    end
    it 'includes height and width attributes' do
      page.find('[data-sul-embed-toggle="sul-embed-embed-this-panel"]', match: :first).click
      expect(page.find('.sul-embed-embed-this-panel textarea').value).to match(%r{<iframe.*height='200px'.*/>}m)
      expect(page.find('.sul-embed-embed-this-panel textarea').value).to match(%r{<iframe.*width='100%'.*/>}m)
    end
  end
  describe 'file objects' do
    let(:spec_fixture) { file_purl }
    it 'are present after a user clicks the button' do
      expect(page).to have_css('.sul-embed-embed-this-panel', visible: false)
      page.find('[data-sul-embed-toggle="sul-embed-embed-this-panel"]', match: :first).click
      expect(page).to have_css('.sul-embed-embed-this-panel', visible: true)
      page.find('[data-sul-embed-toggle="sul-embed-embed-this-panel"]', match: :first).click
      expect(page).to have_css('.sul-embed-embed-this-panel', visible: false)
    end
    it 'have the form elements for updating the embed code' do
      page.find('[data-sul-embed-toggle="sul-embed-embed-this-panel"]', match: :first).click
      expect(page).to have_css('.sul-embed-options-label', text: 'SELECT OPTIONS:')
      expect(page).to have_css('input#sul-embed-embed-title[type="checkbox"]')
      expect(page).to have_css('input#sul-embed-embed-search[type="checkbox"]')
      expect(page).to have_css('input#sul-embed-embed[type="checkbox"]')
      expect(page).to have_css('textarea#sul-embed-iframe-code')
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
