require "rails_helper"

class TestViewerClass; end

describe Embed do
  describe 'registering viewers' do
    it 'should have an empty registered_viewers array' do
      expect(Embed.registered_viewers).to be_a(Array)
      expect(Embed.registered_viewers.count).to eq 1
    end
    it 'should allow viewers to be registered' do
      Embed.register_viewer(TestViewerClass)
      expect(Embed.registered_viewers).to be_a(Array)
      expect(Embed.registered_viewers).to include TestViewerClass
    end
  end
end
