import { defineConfig } from 'vite'
import VuePlugin from "@vitejs/plugin-vue";
import RubyPlugin from 'vite-plugin-ruby'

export default defineConfig({
  plugins: [
    VuePlugin(),
    RubyPlugin()
  ],
  resolve: {
    alias: {
      '@fae/': `${process.env.FAE_PATH}/`,
    },
  },
  server: {
    fs: {
      allow: [process.env.FAE_PATH]
    },
  },  
})
