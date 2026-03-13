import { defineConfig } from "vite";
import vue from "@vitejs/plugin-vue";

const backendHost = process.env.VITE_API_HOST || "localhost";

export default defineConfig({
  plugins: [vue()],
  server: {
    port: 5173,
    host: "0.0.0.0",
    proxy: {
      "/api": {
        target: `http://${backendHost}:8080`,
        changeOrigin: true,
      },
      "/ws": {
        target: `ws://${backendHost}:8080`,
        ws: true,
      },
    },
  },
});
