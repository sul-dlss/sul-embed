# frozen_string_literal: true

require 'rails_helper'

class TestViewerClass
  def self.supported_types
    [:test_view]
  end
end

describe Embed do
  describe 'registering viewers' do
    it 'has an array of registered_viewers' do
      expect(described_class.registered_viewers).to be_a(Array)
      expect(described_class.registered_viewers.count).to be > 1
      expect(described_class.registered_viewers).to include(Embed::Viewer::File)
    end

    it 'allows viewers to be registered' do
      described_class.register_viewer(TestViewerClass)
      expect(described_class.registered_viewers).to be_a(Array)
      expect(described_class.registered_viewers).to include TestViewerClass
    end

    it 'raises an error if a viewer registers itself w/ a supported type that is already registered' do
      expect { described_class.register_viewer(described_class.registered_viewers.first) }.to raise_error(Embed::DuplicateViewerRegistration)
    end
  end
end
