require 'rails_helper'

describe Embed::Mimetypes do
  let(:dummy_class) { Class.new }
  before { dummy_class.extend(described_class) }

  describe '.pretty_mime' do
    it 'for a known mimetype' do
      expect(dummy_class.pretty_mime('application/pdf')).to eq 'pdf'
    end
    it 'for an unknown mimetype' do
      expect(dummy_class.pretty_mime('text/yolo')).to eq 'text/yolo'
    end
  end
end
