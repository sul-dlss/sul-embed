# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::Mimetypes do
  let(:dummy_class) { Class.new { include Embed::Mimetypes }.new }

  describe '.pretty_mime' do
    it 'for a known mimetype' do
      expect(dummy_class.pretty_mime('application/pdf')).to eq 'pdf'
    end

    it 'for an unknown mimetype' do
      expect(dummy_class.pretty_mime('text/yolo')).to eq 'text/yolo'
    end
  end
end
