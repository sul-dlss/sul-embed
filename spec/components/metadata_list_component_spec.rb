# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MetadataListComponent, type: :component do
  before do
    render_inline(described_class.new(viewer:))
  end

  let(:viewer) { instance_double(Embed::Viewer::Media, purl_object:) }
  let(:purl_object) do
    instance_double(Embed::Purl, purl_url: 'https://purl.stanford.edu/gt507vy5436')
  end

  it 'renders something useful' do
    expect(page).to have_content 'To request a transcript or other assistance'
    expect(page).to have_link 'purl.stanford.edu/gt507vy5436'
  end
end
