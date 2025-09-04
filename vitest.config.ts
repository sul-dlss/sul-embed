/// <reference types="vitest" />
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import { fileURLToPath } from 'url';
import fs from 'fs/promises';
import path from 'path';

export default defineConfig({
  esbuild: {
    exclude: [],
    include: [
      /spec\/javascript\/.*\.jsx?$/,          // your tests
      /app\/javascript\/src\/.*\.jsx?$/, // your source files
    ],
    loader: 'jsx',
  },
  optimizeDeps: {
    esbuildOptions: {
      plugins: [
        {
          name: 'load-js-files-as-jsx',
          setup(build) {
            build.onLoad({ filter: /spec\/react\/.*\.js$/ }, async (args) => ({
              contents: await fs.readFile(args.path, 'utf8'),
              loader: 'jsx',
            }));
          },
        },
      ],
    },
  },
  plugins: [react()],
  resolve: {
    alias: {
      '@tests': fileURLToPath(new URL('./spec/javascript', import.meta.url)),
      '@': path.resolve(__dirname, 'app/javascript/src'),
    },
  },
  test: {
    environment: 'happy-dom',
    exclude: ['node_modules'],
    globals: true,
    include: ['spec/javascript/**/*.test.js', 'spec/javascript/**/*.test.jsx'],
    sequence: {
      shuffle: true,
    },
    setupFiles: ['./spec/javascript/setupVitest.js'],
  },
});
