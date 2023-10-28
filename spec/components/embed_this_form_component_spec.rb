# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EmbedThisFormComponent, type: :component do
  let(:request) do
    Embed::Request.new(url: 'http://purl.stanford.edu/abc123')
  end
  let(:object) { instance_double(Embed::Purl, title: '', druid: '', all_resource_files: [], embargoed?: false) }
  let(:viewer) { Embed::Viewer::File.new(request) }

  before do
    allow(request).to receive(:purl_object).and_return(object)
  end

  context 'without any content' do
    before do
      render_inline(described_class.new(viewer:))
    end

    it 'has the form elements for updating the embed code' do
      expect(page.find('.sul-embed-options-label#select-options')).to have_content('Select options:')
      expect(page).to have_css('input#sul-embed-embed-title[type="checkbox"]')
      expect(page).to have_css('input#sul-embed-embed[type="checkbox"]')
      expect(page).to have_css('textarea#sul-embed-iframe-code')
    end
  end

  context 'with content' do
    before do
      with_controller_class EmbedController do
        render_inline(described_class.new(viewer:)) do
          vc_test_controller.helpers.tag :input, type: 'checkbox', id: 'sul-embed-embed-search'
        end
      end
    end

    it 'has the form elements for updating the embed code' do
      expect(page.find('.sul-embed-options-label#select-options')).to have_content('Select options:')
      expect(page).to have_css('input#sul-embed-embed-title[type="checkbox"]')
      expect(page).to have_css('input#sul-embed-embed-search[type="checkbox"]')
      expect(page).to have_css('input#sul-embed-embed[type="checkbox"]')
      expect(page).to have_css('textarea#sul-embed-iframe-code')
    end
  end
end
