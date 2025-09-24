import { vi, describe, it, expect, beforeEach } from 'vitest'
import { trackView } from '@/modules/metrics.js'

describe('trackView', () => {
  beforeEach(() => {
    // Reset global ahoy mock before each test
    global.ahoy = { trackView: vi.fn() }

    // Mock document.referrer
    Object.defineProperty(document, 'referrer', {
      value: 'https://example.com/some/path',
      configurable: true,
    })

    // Mock window.location.search
    const search = '?url=https%3A%2F%2Fpurl.stanford.edu%2Fab123cd4567'
    delete window.location
    window.location = new URL(`https://embed.stanford.edu/viewer${search}`)
  })

  it('calls ahoy.trackView with correct event parameters', () => {
    trackView()

    expect(global.ahoy.trackView).toHaveBeenCalledWith({
      url: 'https://example.com/some/path',
      page: '/some/path',
      druid: 'ab123cd4567',
    })
  })
})
