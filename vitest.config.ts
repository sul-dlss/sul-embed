/// <reference types="vitest" />
import { defineConfig } from "vite"
import react from "@vitejs/plugin-react"
import { fileURLToPath } from "url"
import path from "path"

// Vite transforms with oxc now rather than esbuild, and oxc decides whether to parse JSX from the
// file extension. The esbuild block that used to live here forced the jsx loader onto .js files and
// is ignored under oxc, which is why anything with JSX in a .js file has to be named .jsx.
export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      "@tests": fileURLToPath(new URL("./spec/javascript", import.meta.url)),
      "@": path.resolve(__dirname, "app/javascript/src"),
    },
  },
  test: {
    environment: "happy-dom",
    exclude: ["node_modules"],
    globals: true,
    include: ["spec/javascript/**/*.test.js", "spec/javascript/**/*.test.jsx"],
    sequence: {
      shuffle: true,
    },
    setupFiles: ["./spec/javascript/setupVitest.js"],
  },
})
