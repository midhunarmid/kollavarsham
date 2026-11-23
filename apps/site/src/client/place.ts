// The visitor's place, chosen in the header's picker and kept in this
// browser only. Pages are built for Thiruvananthapuram; when another place
// is chosen, page scripts recompute their times with the engine
// (kollavarsham.js, loaded on demand). Nothing leaves the browser.

export interface Place {
  id: string;
  ml: string;
  en: string;
  lat: number;
  lng: number;
  tz: string;
  kerala?: boolean;
}

/** The engine's day, as `kollavarsham.dayOf` returns it. */
export interface EngineSpan { id: string | number; until: string; ml: string; en: string }
export interface EngineDay {
  stars: EngineSpan[];
  tithis: EngineSpan[];
  paksha: string;
  pakshaMl: string;
  pakshaEn: string;
  sunrise: string | null;
  sunset: string | null;
  moonrise: string | null;
  moonset: string | null;
  kalams: Record<string, [string, string]>;
  kalamNames: Record<string, { ml: string; en: string }>;
}

interface Engine {
  dayOf(iso: string, lat: number, lng: number, offsetMinutes: number): EngineDay | null;
}

const key = 'place';
/** The place the static pages are computed for. */
export const defaultPlace = 'thiruvananthapuram';

function stored(): string {
  try {
    return localStorage.getItem(key) ?? defaultPlace;
  } catch {
    return defaultPlace;
  }
}

function store(id: string) {
  try {
    if (id === defaultPlace) localStorage.removeItem(key);
    else localStorage.setItem(key, id);
  } catch {
    // Private mode or blocked storage: the choice lasts for this page.
  }
}

let places: Place[] = [];
let current = stored();

/** The chosen place, or null for the default (the static pages' place). */
export function chosenPlace(): Place | null {
  if (current === defaultPlace) return null;
  return places.find((p) => p.id === current) ?? null;
}

/**
 * Minutes east of UTC of time zone `tz` at noon UTC on `iso` (yyyy-mm-dd),
 * or at the instant `at` (ms).
 */
export function offsetMinutes(tz: string, iso?: string, at?: number): number {
  const instant = Math.floor((at ?? Date.parse(`${iso}T12:00:00Z`)) / 60000) * 60000;
  const parts = Object.fromEntries(
    new Intl.DateTimeFormat('en-US', {
      timeZone: tz, hourCycle: 'h23', year: 'numeric', month: '2-digit', day: '2-digit',
      hour: '2-digit', minute: '2-digit',
    }).formatToParts(new Date(instant)).map((p) => [p.type, p.value]),
  );
  const wall = Date.UTC(+parts.year, +parts.month - 1, +parts.day, +parts.hour, +parts.minute);
  return Math.round((wall - instant) / 60000);
}

/** "UTC+04:00". */
export function offsetLabel(minutes: number): string {
  const sign = minutes < 0 ? '−' : '+';
  const m = Math.abs(minutes);
  return `UTC${sign}${String(Math.floor(m / 60)).padStart(2, '0')}:${String(m % 60).padStart(2, '0')}`;
}

/** Minutes east of UTC now at `place`, or in Kerala. */
export const offsetNow = (place: Place | null) =>
  place ? offsetMinutes(place.tz, undefined, Date.now()) : 330;

/** The wall-clock time now at `place` (or in Kerala), yyyy-mm-ddThh:mm. */
export const nowAt = (place: Place | null) =>
  new Date(Date.now() + offsetNow(place) * 60000).toISOString().slice(0, 16);

/**
 * A Kerala wall-clock time (yyyy-mm-ddThh:mm, IST) on another clock,
 * `offset` minutes east of UTC.
 */
export function fromIst(local: string, offset: number): string {
  const utc = Date.parse(`${local}:00Z`) - 330 * 60000;
  return new Date(utc + offset * 60000).toISOString().slice(0, 16);
}

let engine: Promise<Engine> | undefined;

/** The engine, loading /kollavarsham.js the first time. */
export function loadEngine(): Promise<Engine> {
  const w = window as unknown as { kollavarsham?: Engine };
  if (w.kollavarsham) return Promise.resolve(w.kollavarsham);
  engine ??= new Promise((resolve, reject) => {
    const existing = document.querySelector<HTMLScriptElement>('script[src="/kollavarsham.js"]');
    const script = existing ?? document.createElement('script');
    const done = () => (w.kollavarsham ? resolve(w.kollavarsham) : reject(new Error('engine missing')));
    script.addEventListener('load', done);
    script.addEventListener('error', () => reject(new Error('engine failed to load')));
    if (!existing) {
      script.src = '/kollavarsham.js';
      document.head.appendChild(script);
    }
  });
  return engine;
}

/** The engine's day `iso` at `place`. */
export async function dayAt(iso: string, place: Place): Promise<EngineDay | null> {
  const k = await loadEngine();
  return k.dayOf(iso, place.lat, place.lng, offsetMinutes(place.tz, iso));
}

type Listener = (place: Place | null) => void;
const listeners: Listener[] = [];
let ready = false;

/**
 * Calls `listener` whenever the visitor picks another place, and once the
 * places are loaded if the stored choice is not the default.
 */
export function onPlace(listener: Listener) {
  listeners.push(listener);
  if (ready && chosenPlace()) listener(chosenPlace());
}

function notify() {
  const place = chosenPlace();
  for (const l of listeners) l(place);
}

/** Fills and shows the header's picker. */
export async function initPicker() {
  const label = document.querySelector<HTMLElement>('label.place');
  const select = document.getElementById('place') as HTMLSelectElement | null;
  if (!label || !select) return;
  try {
    places = await (await fetch('/places.json')).json();
  } catch {
    return; // Offline without a cached copy: the page stays as built.
  }
  const lang = label.dataset.lang === 'ml' ? 'ml' : 'en';
  const groups: string[] = JSON.parse(label.dataset.groups ?? '[]');
  const parts = [
    places.filter((p) => p.kerala),
    places.filter((p) => !p.kerala && p.tz === 'Asia/Kolkata'),
    places.filter((p) => p.tz !== 'Asia/Kolkata'),
  ];
  parts.forEach((list, i) => {
    const group = document.createElement('optgroup');
    group.label = groups[i] ?? '';
    for (const p of list) group.appendChild(new Option(p[lang], p.id));
    select.appendChild(group);
  });
  if (!places.some((p) => p.id === current)) current = defaultPlace;
  select.value = current;
  label.hidden = false;
  select.addEventListener('change', () => {
    current = select.value;
    store(current);
    notify();
  });
  ready = true;
  if (chosenPlace()) notify();
}
