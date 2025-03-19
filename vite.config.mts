import RubyPlugin from "vite-plugin-ruby";
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

export default defineConfig({
  // RubyPlugin links with the config/vite.json file,
  plugins: [react(), RubyPlugin()],
  build: {
    emptyOutDir: true,
    manifest: true,
    minify: false,
    sourcemap: "inline",
    rollupOptions: {
      // Externalize deps that shouldn't be bundled
      external: ["react", "react-dom", "react/jsx-runtime"],
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
