import RubyPlugin from "vite-plugin-ruby";
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

export default defineConfig({
  // RubyPlugin links with the config/vite.json file,
  plugins: [react(), RubyPlugin()],
  define: {
    'process.env.RAILS_ENV': JSON.stringify(process.env.RAILS_ENV || 'production'),
  },
  build: {
    emptyOutDir: true,
    manifest: true,
    minify: false,
    sourcemap: "inline",
    rollupOptions: {
      output: {
        // Provide global variables to use in the UMD build for externalized deps
        globals: {
          react: "React",
          "react-dom": "React-dom",
          "react/jsx-runtime": "react/jsx-runtime",
        },
      },
    },
  },
});
