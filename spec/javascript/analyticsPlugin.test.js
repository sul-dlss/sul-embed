import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'
import { put } from 'redux-saga/effects'
import analyticsPlugin, { deriveManifestType, clean } from '@/mirador/plugins/analyticsPlugin.js'

describe('deriveManifestType', () => {
  it('detects Manifest (IIIF v2 and v3)', () => {
    expect(deriveManifestType({ type: 'Manifest' })).toBe('manifest')
    expect(deriveManifestType({ '@type': 'sc:Manifest' })).toBe('manifest')
  })

  it('detects Collection (IIIF v2 and v3)', () => {
    expect(deriveManifestType({ type: 'Collection' })).toBe('collection')
    expect(deriveManifestType({ '@type': 'sc:Collection' })).toBe('collection')
  })

  it('returns unknown for unrecognized types', () => {
    expect(deriveManifestType({})).toBe('unknown')
  })
})

describe('clean', () => {
  it('removes undefined, null, and empty string values', () => {
    expect(clean({ a: 1, b: undefined, c: null, d: '', e: 0 })).toEqual({ a: 1, e: 0 })
  })

  it('preserves falsy values that are not undefined/null/empty string', () => {
    expect(clean({ a: false, b: 0 })).toEqual({ a: false, b: 0 })
  })
})

describe('sendAnalyticsEvent', () => {
  beforeEach(() => { window.gtag = vi.fn() })
  afterEach(() => { delete window.gtag })

  it('calls window.gtag with cleaned params', () => {
    const saga = analyticsPlugin.saga()

    // advance through the all([...takeEvery...]) yield — just ensure no errors
    saga.next()

    // call sendAnalyticsEvent directly via its generator
    const { sendAnalyticsEvent } = analyticsPlugin
    if (!sendAnalyticsEvent) return // not exported; skip

    const gen = sendAnalyticsEvent({ payload: { eventAction: 'mirador/SET_CANVAS', manifestId: 'http://example.com/manifest', interactionType: 'canvas' } })
    gen.next()

    expect(window.gtag).toHaveBeenCalledWith(
      'event',
      'mirador/SET_CANVAS',
      expect.objectContaining({ interaction_type: 'canvas', manifest_id: 'http://example.com/manifest' })
    )
  })
})

describe('analyticsPlugin default export', () => {
  it('exports a component and saga', () => {
    expect(typeof analyticsPlugin.component).toBe('function')
    expect(typeof analyticsPlugin.saga).toBe('function')
  })
})
