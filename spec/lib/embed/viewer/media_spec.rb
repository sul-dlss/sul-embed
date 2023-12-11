# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::Viewer::Media do
  let(:request) { instance_double(Embed::Request, purl_object: instance_double(Embed::Purl)) }
  let(:media_viewer) { described_class.new(request) }

  describe '#importmap' do
    subject { media_viewer.importmap }

    it { is_expected.to eq 'media' }
  end
end
