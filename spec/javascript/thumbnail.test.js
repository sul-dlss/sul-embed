import Thumbnail from '@/modules/thumbnail.js';

describe('Thumbnail', () => {
  it('build returns expected markup with Stanford only and restriction', () => {
    const thumb = new Thumbnail({
      fileUri: 'http://example.com/file',
      isStanfordOnly: true,
      thumbnailUrl: null,
      defaultIcon: 'icon-class',
      isLocationRestricted: true,
      fileLabel: 'A very long label that should be truncated properly in the markup',
    });

    const html = thumb.build(0);
    expect(html).toContain('sul-embed-thumb-stanford-only');
    expect(html).toContain('(Restricted)');
    expect(html).toContain('default-thumbnail-icon');
    expect(html).toContain('active');
  });

  it('truncateWithEllipsis truncates text correctly', () => {
    const thumb = new Thumbnail({});
    const shortText = 'short';
    expect(thumb.truncateWithEllipsis(shortText, 10)).toBe('short');
    const longText = 'a'.repeat(20);
    expect(thumb.truncateWithEllipsis(longText, 10)).toBe('aaaaaaaaa&hellip;');
  });
});
