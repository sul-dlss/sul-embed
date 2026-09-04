# frozen_string_literal: true

require 'rails_helper'

# NOTE: This test hits the production purl & stacks servers, and CARTO's basemap CDN (via javascript)
RSpec.describe 'georeferenced map in Mirador', :js do
  let(:purl) { build(:purl, :georeferenced_map) }
  # The tab titles come from config/locales/en.yml, so read them from there rather than repeating them
  let(:views) { I18n.t('viewers.mirador_viewer.views') }

  before do
    allow(Embed::Purl).to receive(:find).and_return(purl)
    visit_iframe_response(purl.druid)
  end

  # ogm-viewer components use shadow DOM, so we need to traverse it. <ogm-preview> reaches the page
  # before the custom element is defined, and #shadow_root raises rather than waiting, so wait on the
  # definition landing first. Longer than Capybara's default because nothing is fetched until the Map
  # view is chosen: the viewer comes off a CDN at that point, where the geo viewer has it loaded
  # before its page is interactive.
  def map_shadow_root
    upgraded = "!!document.querySelector('ogm-preview')?.shadowRoot" \
               "?.querySelector('ogm-map')?.shadowRoot"
    deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + 20

    until page.evaluate_script(upgraded)
      raise 'gave up waiting for the map viewer to load' if Process.clock_gettime(Process::CLOCK_MONOTONIC) > deadline

      sleep 0.25
    end

    find('ogm-preview').shadow_root.find('ogm-map').shadow_root
  end

  it 'still opens as the image viewer, with the map offered alongside' do
    expect(page).to have_css('main.mirador-viewer')
    expect(page).to have_css('[role="tab"]', text: views[:image])
    expect(page).to have_css('[role="tab"][aria-selected="true"]', text: views[:image])
    expect(page).to have_css('[role="tab"]', text: views[:map])
  end

  # The map viewer is around a megabyte gzipped, so it is fetched when someone asks for it rather
  # than by everyone who opens a scanned map
  it 'draws no map until its view is chosen' do
    expect(page).to have_css('main.mirador-viewer')
    expect(page).to have_no_css('ogm-preview', visible: :all)

    click_on views[:map]

    expect(map_shadow_root).to have_css('canvas', count: 1)
  end

  # Mirador keeps its own frame: there is one title bar, one sidebar and one set of controls, and the
  # scan is not torn down when the map is shown
  it 'leaves Mirador in charge of the window' do
    expect(page).to have_css('.mirador-window-top-bar')

    click_on views[:map]

    expect(map_shadow_root).to have_css('canvas', count: 1)
    expect(page).to have_css('.mirador-window-top-bar')
    expect(page).to have_css('.openseadragon-container', visible: :all)
  end

  # The tabs replace the image viewer, which sits beside the sidebar rather than containing it - swap
  # them for the whole primary window instead and the window's own sidebar button stops doing
  # anything while the map is up
  it 'keeps the sidebar working while the map is showing' do
    click_on views[:map]
    expect(map_shadow_root).to have_css('canvas', count: 1)

    find('[aria-label="Show sidebar"]').click

    expect(page).to have_text('About this item')
  end

  # Left transparent, the strip sits on the dark backdrop Mirador puts behind an image, where its own
  # near-black labels can't be read - which looks like the viewer honouring a dark colour scheme it
  # doesn't in fact support
  it 'draws the tab strip on a surface of its own' do
    expect(page).to have_css('.sul-view-tabs')

    background = page.evaluate_script("getComputedStyle(document.querySelector('.sul-view-tabs')).backgroundColor")

    expect(background).not_to eq 'rgba(0, 0, 0, 0)'
  end
end
