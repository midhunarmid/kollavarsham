// calendar.armid.in: English at /, Malayalam under /ml/. The Flutter web
// app is copied into /app/ by the deploy workflow.
import { defineConfig } from 'astro/config';
import sitemap from '@astrojs/sitemap';

export default defineConfig({
  site: 'https://calendar.armid.in',
  trailingSlash: 'always',
  build: { format: 'directory' },
  integrations: [
    sitemap({
      i18n: { defaultLocale: 'en', locales: { en: 'en-IN', ml: 'ml-IN' } },
      filter: (page) => !page.includes('/404'),
    }),
  ],
});
