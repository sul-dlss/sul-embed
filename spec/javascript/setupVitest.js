import '@testing-library/jest-dom';
import { vi } from 'vitest';

// vitest doesn't set a default
window.origin = 'http://localhost';

vi.setConfig({ testTimeout: 10_000 });
