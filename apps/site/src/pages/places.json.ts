// /places.json: the header picker's places, fetched once by the browser
// (and cached) rather than repeated in every page.
import { places } from '../lib/data';

export function GET() {
  return new Response(JSON.stringify(places), {
    headers: { 'content-type': 'application/json' },
  });
}
