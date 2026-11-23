// The page images for scripts/og-pages.mjs to render after the build; the
// script deletes this file from dist/ so it is not published.
import { ogEntries } from '../lib/og';

export function GET() {
  return new Response(JSON.stringify(ogEntries), {
    headers: { 'content-type': 'application/json' },
  });
}
