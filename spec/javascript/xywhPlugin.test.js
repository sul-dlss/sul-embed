import { describe, it, vi, beforeEach, afterEach, expect } from 'vitest';
import { render, cleanup } from '@testing-library/react';
import xywhPlugin from '@/mirador/plugins/xywhPlugin.js';
const XywhPluginComponent = xywhPlugin[0].component;

describe('xywhPlugin', () => {
  let viewerMock;
  let parentNode;

  beforeEach(() => {
    parentNode = document.createElement('div');
    parentNode.setAttribute('id', 'mock-parent');

    viewerMock = {
      element: {
        parentNode: parentNode,
      },
      addHandler: vi.fn(),
      removeHandler: vi.fn(),
    };
  });

  afterEach(() => {
    cleanup();
    vi.clearAllMocks();
  });

  it('sets data-parent-window-id attribute on mount', () => {
    render(<XywhPluginComponent viewer={viewerMock} windowId="abc123" />);
    expect(parentNode.getAttribute('data-parent-window-id')).toBe('abc123');
  });

  it('adds animation-finish handler on mount', () => {
    render(<XywhPluginComponent viewer={viewerMock} windowId="abc123" />);
    expect(viewerMock.addHandler).toHaveBeenCalledWith('animation-finish', expect.any(Function));
  });

  it('sets data-full-image attribute on parentNode when animation-finish event fires', () => {
    let animationFinishHandler;

    // Capture the handler passed to addHandler
    viewerMock.addHandler.mockImplementation((eventName, handler) => {
      if (eventName === 'animation-finish') animationFinishHandler = handler;
    });

    render(<XywhPluginComponent viewer={viewerMock} windowId="abc123" />);

    // Simulate the animation-finish event
    const mockEvent = {
      eventSource: {
        element: { parentNode },
        viewport: {
          getBounds: () => ({ x: 0, y: 0, width: 100, height: 200 }),
          viewportToImageRectangle: () => ({ x: 0, y: 0, width: 100, height: 200 }),
          viewer: {
            source: { _id: 'http://example.com/image' },
            world: { getItemCount: () => 1 },
          },
        },
      },
    };

    // Call the captured handler with the mock event
    animationFinishHandler(mockEvent);

    // Check that the attribute was set correctly
    expect(parentNode.getAttribute('data-full-image')).toBe(
      'http://example.com/image/0,0,100,200/full/0/default.jpg'
    );
  });

  it('removes animation-finish handler on unmount', () => {
    const { unmount } = render(<XywhPluginComponent viewer={viewerMock} windowId="abc123" />);
    unmount();
    expect(viewerMock.removeHandler).toHaveBeenCalledWith('animation-finish', expect.any(Function));
  });
});
