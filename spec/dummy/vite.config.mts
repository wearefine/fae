import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'
import vue from '@vitejs/plugin-vue'
import path from 'node:path'

// The gem root. The dummy app lives at spec/dummy, but Fae's own Vue source
// ships from the engine at <gem>/app/frontend.
const engineRoot = path.resolve(import.meta.dirname, '../..')
const nodeModules = path.resolve(import.meta.dirname, 'node_modules')

export default defineConfig({
  plugins: [RubyPlugin(), vue()],

  resolve: {
    alias: {
      // Stands in for the published npm package. A real host app resolves
      // this from node_modules; here we point straight at the engine source
      // so changes to Fae are picked up without a publish step.
      '@fae': path.resolve(engineRoot, 'app/frontend'),

      // Because the engine source lives above this app, Node's upward module
      // resolution walks /app/app -> /app and never reaches
      // spec/dummy/node_modules. Pinning these keeps the engine and the host
      // on one copy of Vue. A real host app gets this for free, since Fae
      // would resolve from its own node_modules.
      vue: path.resolve(nodeModules, 'vue'),
      '@inertiajs/vue3': path.resolve(nodeModules, '@inertiajs/vue3'),
    },
    dedupe: ['vue', '@inertiajs/vue3'],
  },

  server: {
    host: '0.0.0.0',
    port: 3036,
    strictPort: true,

    // Rails proxies /vite-dev requests to this container, so the Host header
    // arrives as the compose service name. Vite 6 rejects unknown hosts as
    // DNS-rebinding protection, so allowlist just what we need rather than
    // disabling the check with `true`.
    allowedHosts: ['localhost', 'vite'],

    fs: {
      // Vite's root is spec/dummy, but the engine source it imports lives
      // above that, so serving files from the gem root must be allowed.
      allow: [engineRoot],
    },

    // Bind mounts on macOS and Windows do not propagate inotify events into
    // the container, so file watching silently never fires without polling.
    watch: {
      usePolling: true,
      interval: 300,
    },

    hmr: {
      // The browser runs on the host, not in the container, so the HMR
      // websocket has to target the published port on localhost rather than
      // the compose service hostname that Rails uses.
      host: 'localhost',
      clientPort: 3036,
      protocol: 'ws',
    },
  },
})
