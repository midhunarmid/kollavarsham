// Lighthouse CI for calendar.armid.in, run by the deploy workflow on the
// built dist/ (site plus the Flutter app at /app/):
//
//   npx @lhci/cli@0.16.0 autorun
//
// Site pages must score at least 95 (SEO 100) on Lighthouse's default
// mobile profile (simulated slow 4G). The web app is held to its recorded
// baseline: transfer size and time to interactive may grow by 10% at most.
// After a deliberate change, update lighthouse-baseline.json.
const baseline = require('./lighthouse-baseline.json');

// Pages that exist in every build: the data covers two years back from
// the build year, so last year's pages are always there.
const year = new Date(Date.now() + 330 * 60000).getUTCFullYear() - 1;
const base = 'http://localhost:8790';
const pages = [
  '/',
  '/ml/',
  `/day/${year}-08-17/`,
  `/ml/day/${year}-08-17/`,
  `/festival/thiruvonam/${year}/`,
  `/ml/festival/thiruvonam/${year}/`,
  '/converter/',
  `/calendar/${year}/`,
];

module.exports = {
  ci: {
    collect: {
      startServerCommand: 'node scripts/serve.mjs 8790',
      startServerReadyPattern: 'Serving dist',
      url: [...pages.map((p) => base + p), `${base}/app/`],
      numberOfRuns: 3,
      settings: { chromeFlags: '--no-sandbox --headless=new' },
    },
    assert: {
      assertMatrix: [
        {
          matchingUrlPattern: '^http://localhost:8790/(?!app/)',
          aggregationMethod: 'median-run',
          assertions: {
            'categories:performance': ['error', { minScore: 0.95 }],
            'categories:accessibility': ['error', { minScore: 0.95 }],
            'categories:best-practices': ['error', { minScore: 0.95 }],
            'categories:seo': ['error', { minScore: 1 }],
            // Bytes over the wire, fonts and the converter script included.
            'total-byte-weight': ['error', { maxNumericValue: 250000 }],
          },
        },
        {
          matchingUrlPattern: '^http://localhost:8790/app/',
          aggregationMethod: 'median-run',
          assertions: {
            'total-byte-weight': ['error', { maxNumericValue: Math.round(baseline.app.totalByteWeight * 1.1) }],
            interactive: ['error', { maxNumericValue: Math.round(baseline.app.interactiveMs * 1.1) }],
          },
        },
      ],
    },
    // Reports stay on the runner (uploaded as a workflow artifact), never
    // on a public server.
    upload: { target: 'filesystem', outputDir: '.lighthouseci/reports' },
  },
};
