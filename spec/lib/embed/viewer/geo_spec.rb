require 'rails_helper'

describe Embed::Viewer::Geo do
  describe 'self.supported_types' do
    it 'should return an array of supported types' do
      expect(Embed::Viewer::Geo.supported_types).to eq [:geo]
    end
  end
end